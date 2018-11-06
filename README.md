# arb-projectionmapping

Platformer ist eine Processing-Applikation, die in Zusammenarbeit mit einem Projektor eine Mixed-Reality Visualisierung von einem Steuerpult implementiert.

Es werden für die Ober- und Unterseite jeweils einzelne Bilder angezeigt.

## Setup
- Der Sketch arb-projection-mapping.pde soll mit der `processing-java` CLI ausgeführt werden.
- Zur Kalibration drücken sie `C` und ziehen Sie die Ecken der zwei Bildflächen mit der Maus an die richtige Stelle. `S` speichert die neue Einstellung.
- Die Bilder befinden sich im data-Ordner.

## Implementationsdetails
- Der Sketch versucht sich mit einem MQTT Server an der Adresse 192.168.100.40 zu verbinden.
- Zur Steuerung werden die MQTT-Topics `horizon/4/projection/state` und `horizon/4/bridge/state` verwendet.
- Je nach Slide wird die Nummer des aktuellen Bilds gesendet.
- Die MQTT-Signale vom Steuerpult geben das aktuelle Bild vor.

