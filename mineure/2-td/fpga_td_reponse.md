# TD FPGA réponse

## Séance 1 : Tuto modelsim, bases, arithmétique

### Tutoriel Modelsim

#### Création d'un premier composant

Le composant de départ est [composant_nul.vhd](1-tuto_modelsim/composant_nul.vhd).

5. Ce composant est une porte qui ne fait rien : il recopie directement l'entrée `sw` vers la sortie `led` (`led <= sw;`). Il n'y a aucune logique, donc la sortie suit l'entrée sans délai de mémorisation, c'est un simple fil.

#### Écriture du test-bench

Le test-bench est [composant_nul_tb.vhd](1-tuto_modelsim/composant_nul_tb.vhd).

3. Explication du code :
   - L'entité du test-bench est vide, c'est une obligation : un test-bench n'a aucun port, car il n'est pas connecté à l'extérieur.
   - Dans l'architecture, on déclare les signaux `tb_sw` et `tb_led`. Ce sont eux que l'on manipule dans le test-bench, ils sont ensuite reliés aux ports du composant à tester.
   - `uut: entity work.composant_nul port map (...)` instancie le composant à tester (_Unit Under Test_). Le `entity work.composant_nul` permet d'instancier le composant `composant_nul` qui se trouve dans la librairie `work` (la librairie par défaut). Le `port map` associe chaque port du composant à un signal du test-bench : `sw => tb_sw` et `led => tb_led`.
   - Le `process` applique une séquence de valeurs sur `tb_sw` (`'0'`, `'1'`, `'0'`, `'1'`), en laissant 10 ns entre chaque changement. On peut ensuite observer dans ModelSim que `tb_led` reproduit exactement ces valeurs.

4. Le `process` se termine par `wait;` sans durée. Un process sans liste de sensibilité s'exécute en boucle tant qu'il n'est pas suspendu : sans ce `wait` final, la séquence recommencerait indéfiniment. Ce `wait` infini indique au simulateur que ce process n'a plus rien à faire, ce qui permet à la simulation de se terminer quand il n'y a plus d'événements à traiter.

#### Fichier de simulation

Le script [composant_nul.do](1-tuto_modelsim/composant_nul.do) compile les deux fichiers VHDL (`vcom`), lance la simulation du test-bench (`vsim`), ajoute les signaux à la fenêtre de forme d'onde (`add wave`) puis lance la simulation complète (`run -all`).

#### Simulation avec Modelsim

Le principe : on se place dans le dossier contenant les fichiers avec `cd`, et on exécute le script avec `do composant_nul.do`. Les signaux que l'on a ajoutés (via `add wave`) apparaissent alors dans la fenêtre `wave` de ModelSim (Si elle n'apparaît pas automatiquement on peut la faire apparaître dans le menu `View` > `Wave`). L'entrée `sw` est affichée en jaune, la sortie `led` en vert (couleur par défaut), et on peut utiliser la loupe (ou le racourci `F`) pour voir l'ensemble de la simulation.

### Encodeur/Décodeur

**Fichier VHDL du décodeur 2 vers 4 :** [decoder.vhd](1-tuto_modelsim/decoder.vhd), j'ai choisi de faire le décodeur avec une architecture de type `<Sortie> when <Condition> else`.

Le test-bench associé est [decoder_tb.vhd](1-tuto_modelsim/decoder_tb.vhd). Il applique successivement les quatre combinaisons valides puis une entrée indéterminée, ce qui permet de vérifier les quatre cas de la table de vérité et le cas indéterminé.

### Multiplexeur

Le multiplexeur sélectionne une des deux entrées selon la valeur de `sel`. Il est décrit dans [multiplexer.vhd](1-tuto_modelsim/multiplexer.vhd).

Sa taille de bus est configurable grâce au `generic BUS_WIDTH` (valeur par défaut `8`). Les ports `in0`, `in1` et `data_out` sont dimensionnés par `BUS_WIDTH`, ce qui permet de réutiliser le même code pour n'importe quelle largeur. Le test-bench [multiplexer_tb.vhd](1-tuto_modelsim/multiplexer_tb.vhd) fixe `BUS_WIDTH` à `2` et passe la valeur à l'instance via un `generic map`. Il compare la sortie du composant à un signal `theoretical_out` contenant la valeur attendue à chaque étape (les deux lignes sont positionnées l'une en dessous dans la fenêtre `wave` de l'autre pour faciliter la comparaison).

### ALU

L'ALU (Arithmetic and Logic Unit) effectue une opération choisie parmi plusieurs sur deux opérandes. Le code est dans [alu.vhd](1-tuto_modelsim/alu.vhd).

1. Combien de bits de sélection sont nécessaires ? Huit opérations demandent `log2(8) = 3` bits. Le signal `sel` est donc un `std_logic_vector(2 downto 0)` : `000` pour l'addition, `001` la soustraction, `010` la multiplication, `011` la division, `100` le OU, `101` le ET, `110` le OU-exclusif et `111` le NON logique de `data_in0`.

2. Schéma : ![TODO](https://img.shields.io/badge/TODO-blue)

3. Code VHDL : le choix de l'opération est fait par une suite de `when ... else` qui teste la valeur de `sel`. Quelques points importants :
   - Les opérandes sont de type `signed`, et on utilise la librairie `numeric_std` qui fournit les opérateurs arithmétiques sur ce type.
   - La multiplication de deux opérandes sur 8 bits produit un résultat sur 16 bits. Le code le ramène à 8 bits avec `resize(..., 8)`. Cela tronque les résultats trop grands : par exemple `9 * 3 = 27` tient sur 8 bits, c'est nécessaire pour que le résultat tienne sur la sortie `data_out` qui est sur 8 bits (on doit choisir une taille de bus pour l'ALU qui ne dépende pas de l'opération donc on prend la taille des opérandes).
   - La dernière branche `(data_out'range => 'U')` gère les codes de sélection non définis.

4. Test-bench : [alu_tb.vhd](1-tuto_modelsim/alu_tb.vhd) applique les opérandes `9` et `3`, puis parcourt les huit codes de sélection. Pour chaque opération, le signal `theoretical_out` contient le résultat attendu : `12`, `6`, `27`, `3`, `11`, `1`, `10` et `-10`. Le premier cas, `sel = "UUU"`, vérifie le comportement face à une sélection indéterminée. Le script [alu.do](1-tuto_modelsim/alu.do) permet de lancer cette simulation, on affiche les signaux dans la fenêtre `wave` et on peut vérifier que la sortie `data_out` correspond bien à la valeur attendue dans `theoretical_out`.
