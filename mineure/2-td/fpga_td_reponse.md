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
   - La multiplication de deux opérandes sur 8 bits produit un résultat sur 16 bits. Le code le ramène à 8 bits avec `resize(..., 8)`. Cela tronque les résultats trop grands ce qui les rendra faux, mais c'est nécessaire pour que le résultat tienne sur la sortie `data_out` qui est sur 8 bits (on doit choisir une taille de bus pour l'ALU qui ne dépende pas de l'opération donc on prend la taille des opérandes).
   - La dernière branche `(data_out'range => 'U')` gère les codes de sélection non définis.

4. Test-bench : [alu_tb.vhd](1-tuto_modelsim/alu_tb.vhd) applique les opérandes `9` et `3`, puis parcourt les huit codes de sélection. Pour chaque opération, le signal `theoretical_out` contient le résultat attendu : `12`, `6`, `27`, `3`, `11`, `1`, `10` et `-10`. Le premier cas, `sel = "UUU"`, vérifie le comportement face à une sélection indéterminée. Le script [alu.do](1-tuto_modelsim/alu.do) permet de lancer cette simulation, on affiche les signaux dans la fenêtre `wave` et on peut vérifier que la sortie `data_out` correspond bien à la valeur attendue dans `theoretical_out`.

## Séance 2 : Circuits séquentiels

### La bascule D

1. Une bascule D est un circuit séquentiel qui permet de mémoriser un bit. Elle a une entrée `D` (Data) et une sortie `Q`. Quand l'horloge `clk` passe de 0 à 1 (front montant), la valeur de `D` est copiée dans `Q`. Ainsi, `Q` garde la valeur précédente de `D` jusqu'au prochain front montant de l'horloge. Il existe aussi une sortie complémentaire `Q_bar` qui vaut l'inverse de `Q` mais elle n'est pas toujours nécessaire. On peut aussi ajouter une entrée de réinitialisation `reset` qui force la sortie `Q` à 0 quand elle est activée et une `enable` qui permet d'activer ou désactiver la mémorisation de la bascule.

2. J'ai implémenter le code VHDL de la bascule D dans le fichier [dff.vhd](2-circuits_sequentiels/dff.vhd). 

3. J'ai choisi de faire une bascule D avec toutes les entrées possibles : `D`, `clk`, `reset` et `enable` mais seulement la sortie `Q` est implémentée. Le code est simple : un `process` sensible à `clk` et `reset`, qui teste d'abord si `reset` est activé, puis sur le front montant de l'horloge, si `enable` est activé, on copie la valeur de `D` dans `Q`.

4. Le test-bench [dff_tb.vhd](2-circuits_sequentiels/dff_tb.vhd). Pour le test-bench, on reprend la même structure que pour les composants précédents, cependant on ajoute un `process` (`clk`) qui génère un signal d'horloge en alternant `0` et `1` toutes les 10 ns, jusqu'à ce que le signal `tb_fin` soit activé, alors on passe dans un `wait` infini pour terminer la simulation. Le second `process` (`uut`) applique une séquence de valeurs sur `tb_i_d`, `tb_i_rst` et `tb_i_en`, synchronisée avec l'horloge (`wait until falling_edge(tb_i_clk);`) afin de vérifier le comportement de la bascule D. Le signal `theoretical_q` contient la valeur attendue de la sortie `Q` à chaque étape, et on peut comparer les deux signaux dans la fenêtre `wave` de ModelSim, en bleu pour la sortie `Q` et en violet pour la valeur attendue `theoretical_q`. Le script [dff.do](2-circuits_sequentiels/dff.do) compile les fichiers VHDL, lance la simulation et affiche les signaux dans la fenêtre `wave`.

5. et 6. Les signaux de reset et d'enable ont été rajoutés dès la question 2.

### Registres (séries et parallèles)

1. Schéma registre série vers série de 4 bits : ![TODO](https://img.shields.io/badge/TODO-blue)

2. Schéma Chronogramme du registre série vers série de 4 bits : ![TODO](https://img.shields.io/badge/TODO-blue)

3. Le fichier VHDL pour le registre série est : [fifo.vhd](2-circuits_sequentiels/fifo.vhd). Le nom du composant est `fifo` car les registres série fonctionnent comme des files (FIFO : First In First Out).

4. Les signaux à mettre dans la `liste de sensibilité` sont les signaux qui doivent déclencher l'exécution du `process`. Dans le cas d'un registre série, on veut que la valeur mémorisée change à chaque front montant de l'horloge, donc on met `clk` dans la liste de sensibilité. Et on veut que le registre se réinitialise quand le signal de reset est activé, donc on met aussi `reset` dans la liste de sensibilité.

5. Pour avoir un registre série vers série avec une profondeur configurable, il existe deux méthodes : 

#### Méthode 1 : redéfinir toutes les bascules D dans un même `process` 

```vhdl
architecture rtl of fifo is
    signal fifo_r_q: std_logic_vector(FIFO_DEPTH downto 0);
begin
    fifo_r_q(0) <= fifo_i_d;

    process(fifo_i_clk, fifo_i_rst)
    begin
        if (fifo_i_rst = '1') then
            fifo_r_q(FIFO_DEPTH downto 1) <= (others => '0');
        elsif rising_edge(fifo_i_clk) then
            if (fifo_i_en = '1') then
                fifo_r_q(FIFO_DEPTH downto 1) <= fifo_r_q(FIFO_DEPTH - 1 downto 0);
            end if;
        end if;
    end process;

    fifo_o_q <= fifo_r_q(FIFO_DEPTH);
end architecture rtl;
```

Avec cette méthode, on reprend l'architecture de la bascule D, mais on ajoute un vecteur de signaux `fifo_r_q` qui contient toutes les valeurs mémorisées par le registre. On redéfinit la valeur de chaque bascule D dans le `process`, en décalant les valeurs à chaque front montant de l'horloge.

#### Méthode 2 : instancier plusieurs bascules D dans une boucle `for`
```vhdl
architecture rtl of fifo is
    signal fifo_r_q: std_logic_vector(FIFO_DEPTH downto 0);
begin
    fifo_r_q(0) <= fifo_i_d;

    gen_dff: for i in 0 to FIFO_DEPTH-1 generate
        dff_i: entity work.dff
            port map (
                i_clk => fifo_i_clk,
                i_en => fifo_i_en,
                i_d => fifo_r_q(i),
                i_rst => fifo_i_rst,
                o_q => fifo_r_q(i + 1)
            );
    end generate gen_dff;

    fifo_o_q <= fifo_r_q(FIFO_DEPTH);
end architecture rtl;
```

C'est cette méthode que j'ai choisie pour implémenter le registre série vers série. Car j'étais parti sur l'idée de réutiliser la bascule D que j'avais déjà implémentée, je suis donc allé chercher sur internet comment instancier un nombre variable d'entités, et j'ai trouvé la méthode de la boucle `for` avec `generate`. Avec cette méthode, on instancie les bascules D une par une, et on relie la sortie de chaque bascule à l'entrée de la suivante. Le signal `fifo_r_q` contient toutes les valeurs mémorisées par le registre, et on peut accéder à la valeur de chaque bascule D avec `fifo_r_q(i)`. Je trouve cette méthode plus intéressante car on ne pourra pas toujours réécrire les codes des composants que l'on veut instancier, et cela peut être intéressant de pouvoir instancier un nombre variable d'entités.

6. J'ai écrit le test-bench [fifo_tb.vhd](2-circuits_sequentiels/fifo_tb.vhd) pour tester le registre série vers série. Le test-bench applique une séquence de valeurs sur l'entrée `fifo_i_d` (`10100...`) après l'activation du enable, et on vérifie que les bascules D commencent à mémoriser les valeurs à partir du moment où le signal `fifo_i_en` est activé. Le signal `theoretical_output` contient la valeur attendue de la sortie `fifo_o_q` à chaque étape, et on peut comparer les deux signaux dans la fenêtre `wave` de ModelSim, en bleu pour la sortie `fifo_o_q` et en violet pour la valeur attendue `theoretical_output`. Le script [fifo.do](2-circuits_sequentiels/fifo.do) lance la simulation et affiche les signaux dans la fenêtre `wave`, par rapport aux précédents composants, j'ai ajouté les signaux internes (en orange) `fifo_r_q(1)`, `fifo_r_q(2)`, `fifo_r_q(3)` et `fifo_r_q(4)` à la fenêtre `wave` de ModelSim, pour voir l'état de chaque bascule D du registre, et on retrouve le chronogramme attendu.

- Fichier VHDL du test-bench : [fifo_tb.vhd](2-circuits_sequentiels/fifo_tb.vhd).
- Fichier de simulation : [fifo.do](2-circuits_sequentiels/fifo.do).

*Note : avec les deux méthodes, j'ai mis le signal `fifo_i_d` sur le premier élément du vecteur `fifo_r_q(0)`, pour faciliter la lecture du code, comme ça les formules pour les bascules D sont plus simples : `fifo_r_q(i + 1) <= fifo_r_q(i)`. c'est pour ça que dans le fichier de simulation `fifo.do` j'ajoute que les signaux internes `fifo_r_q(1)`, `fifo_r_q(2)`, `fifo_r_q(3)` et `fifo_r_q(4)` à la fenêtre `wave` de ModelSim, pour voir l'état de chaque bascule D du registre.*

### Compteurs

1. Schéma de principe d'un compteur générique : ![TODO](https://img.shields.io/badge/TODO-blue)
2. Schéma chronogramme d'un compteur 2 bits : ![TODO](https://img.shields.io/badge/TODO-blue)
3. Le fichier VHDL pour le compteur est : [counter.vhd](2-circuits_sequentiels/counter.vhd).
4. On implémente le compteur avec un `process` sensible à l'horloge et au reset, et en suivant la structure décrite dans le schéma question 1. On utilise un registre `r_count` pour mémoriser la valeur du compteur, et on met à jour ce signal à chaque front montant de l'horloge, et on utilise un signal interne `s_carry` pour gérer le report de l'incrémentation. La sortie `o_count` est reliée à ce signal interne.
5. Le test-bench initialise le compteur, puis attend 4 incrémentations, puis reset le compteur, puis le laisse repartir pour 1 incrémentation afin de vérifier que le compteur repart bien après un reset.

- Le test-bench [counter_tb.vhd](2-circuits_sequentiels/counter_tb.vhd). 
- Le script [counter.do](2-circuits_sequentiels/counter.do).

### FSM

1. `r_state` est initialisé car c'est un registre qui doit mémoriser l'état courant, il a une valeur stable entre deux front d'horloge et il est remis à zéro lors du reset, alors que s_next_state est un signal combinatoire qui n'a donc pas besoin d'être initialisé et est recalculé en permanence.
2. Pour le premier process, la liste de sensibilité contient `i_clk` et `i_rst_n` car il faut que le process s'exécute quand l'horloge change pour passer à l'état suivant, et quand le reset est activé pour revenir à l'état initial. 
    Pour le second process, la liste de sensibilité contient `r_state`, `i_p50` et `i_p100` car il faut que le signal `s_next_state` soit recalculé à chaque changement d'un des signaux qui influencent la transition d'état afin d'être toujours à jour.
3. Schéma d'architecture de la FSM : ![TODO](https://img.shields.io/badge/TODO-blue)
4. Lien entre le code et le schéma : ![TODO](https://img.shields.io/badge/TODO-blue)
5. Schéma graphe d'état du séquenceur : ![TODO](https://img.shields.io/badge/TODO-blue)
6. Chronogramme du séquenceur complété : ![TODO](https://img.shields.io/badge/TODO-blue)