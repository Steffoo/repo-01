% Large-Scale Development (LSD) \newline Assignment 5: Der Build-Server *Jenkins*
% Autoren: Felix Hefner, Max Jando, Severin Kohler
% Stand: \today{}

# Einleitung

Im Rahmen der Vorlesung LSD (Large-Scale-Development) sollten die Autoren dieses Dokuments den Opensource-Build-Server *Jenkins* aufsetzen und eine Build-Pipeline anlegen, welche den in vorherigen Assignments bereits behandelten Tomcat 6.0.5 baut. Dieses Dokument ist in folgende Teile untergliedert:

1. Installation von Jenkins auf einem Ubuntu-Server
2. Konfiguration der Build-Jobs in Jenkins
	1. Erstellung der Jenkinsfiles
	2. Weitere Konfiguration auf der Weboberfläche von Jenkins

# Installation von Jenkins auf einem Ubuntu-Server

Da das Ubuntu Server-Betriebssystem mit der Paketverwaltung \texttt{apt-get} ausgeliefert wird, konnte diese auf relativ simple Weise dazu benutzt werden, das Jenkins-Paket zu installieren. Jedoch war dieses nicht in den Standard-Paketquellen zu finden, sodass eine spezielle von den Entwicklern der Software hinzugefügt werden musste. Im Großen und Ganzen wurde sich hierbei an die offizielle Anleitung[^1] gehalten. Genauer wurde wie folgt vorgegangen:

1. Manuelles Hinzufügen des Publickeys der Jenkins.io - Server, damit diesen vertraut wird
2. Hinzufügen der Jenkins-Paketquelle durch
```bash
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable
binary/ > /etc/apt/sources.list.d/jenkins.list'
```
3. Aktualisieren der Paketquellen sowie Installation des Pakets durch
```bash
sudo apt-get update ; sudo apt-get install jenkins
```
4. Da der Paketmanager nach der Installation von selbst den Befehl \texttt{service start jenkins} aufruft, läuft Jenkins ab sofort unter \texttt{http://<IP-des-Servers>:8080}.

[^1]: [https://wiki.jenkins.io/display/JENKINS/Installing+Jenkins+on+Ubuntu](https://wiki.jenkins.io/display/JENKINS/Installing+Jenkins+on+Ubuntu)

# Konfiguration der Build-Jobs in Jenkins

Die Build-Jobs, die in Jenkins zum Kompilieren des Java-Codes, zum Ausführen der Tests sowie zum Deployen des fertigen \texttt{.jar}-Archivs wurden primär über sogenannte *Pipelines* anhand von *Jenkinsfiles* erstellt. Hierbei handelt es sich um Scripte, welche in der Sprache Groovy geschrieben werden und sich in Stages unterteilen. Dies sind Abschnitte, welche später auch in der Weboberfläche von Jenkins sichtbar werden. Der Inhalt des \texttt{Jenkinsfile} wurde zunächst direkt in der Weboberfläche eingetragen, nach dem ersten Build-Durchlauf konnte jedoch diese Datei aus dem Github-Repository heruntergeladen werden und anschließend von dort verwendet werden. Insgesamt wurden mehrere Build-Jobs für folgende Zwecke erstellt, damit die Aufgaben strikt getrennt sind:

- **Jenkins_CI_Build:** Jenkins-Job zum Kompilieren des Sourcecodes, Testens und erstellen einer \texttt{.jar}-Datei.
- **Jenkins_CI_Deployment:** Deployment (kopieren des \texttt{.jar}-Files an eine definierte stellen sowie beenden des alten Tomcat-Prozesses und starten eines neuen) der Ergebnisse von **Jenkins**.
- **Jenkins_Prod_Build:** Siehe **Jenkins_CI_Build**, lediglich ein weiterer Build, um eventuelle Auslieferung (Production) anbieten zu können, ohne die Entwicklung im CI-Build zu beeinflussen. Dieser Build wird erst gebaut, sobald der CI-Build erfolgreich war.
- **Jenkins_Prod_Deployment:** Analog zu **Jenkins_CI_Deployment**

## Erstellung der Jenkinsfiles

Das folgende Listing zeigt eines der erstellten Jenkinsfiles, welches für dieses Projekt benutzt wurde. Es handelt sich um die Datei \texttt{Jenkinsfile\_CI\_build}, welche für den ersten Build-Job **Jenkins_CI_Build** benutzt wird. Das Script für **Jenkins_Prod_Build** fällt identisch aus. Es wurde jedoch an einem separatem Pfad abgelegt, um es zukünftig leichter austauschen zu können.

~~~{.groovy .numberLines stepnumber=6 frame=single captionpos=b, caption="Jenkinsfile zum Bauen, Testen und Archivieren von Tomcat mit Maven"}
node {

	//-----------------
    stage name: 'clean'
	//-----------------
	
	checkout scm
	env.JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
    env.PATH="${env.JAVA_HOME}/bin:${env.PATH}"
	sh "cd 'tomcat' ; mvn 'clean'"
	
	//-----------------
    stage name: 'compile'
	//-----------------
	
    sh "cd 'tomcat' ; mvn 'compile'"
    
    //-----------------
    stage name: 'test'
    //-----------------
    
    sh "cd 'tomcat' ; mvn test"
    
    //-----------------
    stage name: 'assembly
	//-----------------
	
	sh "cd 'tomcat' ; mvn assembly:single"
}
~~~
Dieses Script ist in die vier Stages *clean*, *compile*, *test* und *assembly* aufgeteilt. In *clean* wird das in Jenkins angegebene SCM[^2] ausgecheckt, die Umgebungsvariablen \texttt{JAVA\_HOME} und \texttt{JAVA\_PATH} gesetzt sowie \texttt{mvn clean} ausgeführt, was die zuvor Kompilierten Dateien löscht. In *compile* wird das gleichnamige Maven-Target aufgerufen, welches den Java-Sourcecode kompiliert. In *test* werden analog dazu mit Maven die Tests ausgeführt. Abschließend wird in *assembly* der Befehl \texttt{mvn assembly:single} auf die Shell gegeben, welcher eine ausführbare \texttt{.jar}-Datei erstellt.

[^2]: Source Code Management

Die Jenkinsfiles für das Deployment fallen deutlich kürzer aus:

~~~{.groovy .numberLines stepnumber=6 frame=single captionpos=b, caption="Jenkinsfile zum Verbreiten von Tomcat mit Maven"}
node {

	//-----------------
	stage name: 'killing_tomcat_process'
	//-----------------
	
	sh '/var/lib/jenkins/kill_tomcat.sh CI'
	
	//-----------------
    stage name: 'copying_files'
	//-----------------
	
	sh 'cp "/var/lib/jenkins/workspace/Tomcat/tomcat/ \   
	target/tomcat-6.0.5-jar-with-dependencies.jar" \   
	"/var/lib/jenkins/tomcat-6.0.5-CI.jar"'
	
	//-----------------
	    stage name: 'starting_tomcat'
	//-----------------
	sh 'cd "/var/lib/jenkins" ; \
	nohup java -jar tomcat-6.0.5-CI.jar &'
}
~~~
Zunächst wird in der Stage *killing_tomcat_process* mit einem kleinen selbstgeschriebenen Script[^3] bei Bedarf der aktuell laufende Tomcat-Prozess beendet. Danach wird das zuvor erzeugte Java-Archive an die vorgesehene Stelle kopiert. Zuletzt wird dieses mithilfe des Befehls \texttt{nohup}, welcher die Ausgabe eines Befehls in eine Log-Datei umleitet, im Hintergrund (durch Verwendung von **&** am Ende des Befehls) gestartet. Hierbei ist noch zu erwähnen, dass die .jar und somit der Tomcat nicht startet, insofern im selben Verzeichnis nicht die Unterverzeichnisse \texttt{conf} und \texttt{webapps} liegen und mit entsprechendem Inhalt gefüllt sind. Ersteres Verzeichnis enhält ein paar Konfiguration zu Tomcat im \texttt{.xml}-Format[^4], letzteres Benutzerinhalt wie Servlets und JSPs.

[^3]: Dieses kann hier bei Github gefunden werden: [Script \texttt{kill\_tomcat.sh} auf Github](https://github.com/lsd-lecture/repo-01/blob/master/kill_tomcat.sh)
[^4]: Hier musste zudem die Datei \texttt{server.xml} bearbeitet werden, um den Standardport *8080* von Tomcat auf *8081* zu ändern, da hier ja bereits der Jenkins läuft.

## Weitere Konfiguration auf der Weboberfläche von Jenkins

Die nachstehende Abbildung zeigt sämtliche Jobs die wir in Jenkins angelegt haben. Die Grünen Ampellichter geben an ob der Build erfolgreich war (Rot=fehlschlag, Grau=schedulded). Das Wetter gibt den durchschnittliche erfolgsrate der letzten 5 builds an je schlechter das Wetter desto mehr Fehlschläge gab es [^5]. 

![Überblick über die Jenkins-Jobs](pictures/job_overview.png)

[^5]: [https://wiki.jenkins.io/display/JENKINS/Dashboard+View](https://wiki.jenkins.io/display/JENKINS/Dashboard+View)

![Überblick der Laufzeiten des Jenkins-Jobs **Tomcat**](pictures/stage_view.png)

In dieser Übersicht sind die einzelnen Build Prozesse (stages) des **Tomcat**-Jobs aufgeführt, sowie ob diese Erfolgreich waren und wie lange sie gebraucht haben. Außerdem wird  die durschnittliche Zeit der Stages angezeigt. 

![Generelle Einstellungen](pictures/general_settings.png)

Hier wird der Name der Pipeline (**Tomcat**) angegeben und welche Art von Projekt (Github-Project) dies ist. Im zusammenhang dazu muss die URL des Repositories angegeben werden von dem dann gebaut wird. 

![Auslöser für den Build](pictures/build_triggers.png)

Mit diesem Parameter wird angegeben in welchen Intervallen überprüft werden soll ob Änderungen im Git-repository stattgefunden haben. In unserem Fall wird dies jede Minute überprüft. Wie Cron-Zeitangaben angegeben werden ist hier [^6] erläutert. Liegen Änderungen vor werden diese gepollt und gebuilded.

[^6]: [https://help.ubuntu.com/community/CronHowto](https://help.ubuntu.com/community/CronHowto)

![Pipeline Einstellungen](pictures/pipeline_settings.png)

Hier werden die Credentials [^7] des Git-Projektes ausgefüllt um sich bei Github zu Authentifizieren. Des Weiteren muss die Git-Branch spezifiziert werden. Als letztes haben wir den Pfad zum Pipeline-Skript angegeben (Jenkinsfile_CI_build)

[^7]: Username und der bei Github hinterlegte Public-Key


Als nächste Einstellung haben wir bestimmt, dass der **Tomcat_Deployment**-Job erst dann ausgeführt wird, wenn der **Tomcat**-Job erfolgreich abgeschlossen wurde. 

![Abhängigkeiten zwischen Jenkins-Jobs](pictures/job_dependencies.png)



