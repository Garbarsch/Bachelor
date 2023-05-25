# github_client

This is the bachelors project of Rasmus Garbarsch and Carl Bruun

##
The project encompass a GUI with interactive elements and implemented Main Memory indexing techniques to improve performance.
It includes:
- A home page that from a map marks amenity and leisure facilities of Denmark, based on chosen metrics and areas (municipalities)
- A graph page that shows detailed statistical information on either different livelihood factors of institution factors, that all serve as choice factors in a students enrollment choice of an education institution.

- A work on spatial indexing:
- R-Tree (R-Tree branch)
- Fixed Grid File
- Adaptive Grid File
- A Novel Polygon Oriented Grid File that sub-partitions intersecting grid cells recursively and sorts these on contaiment in polygons that outline the searched municipality
- The sub-partition technique reduces false positives and lessens the amount of expensive polygon containment checks for separate data points, by charactherizing their containment from the cell wich they reside.


The Application runs as a desktop application.
Usuability is tested with SUS, with a score above average concluding its sufficiency within the scope of an MVP.
Code in the branch is in a state of indexing analysis and is thus not concluded as a final conclusive state.
