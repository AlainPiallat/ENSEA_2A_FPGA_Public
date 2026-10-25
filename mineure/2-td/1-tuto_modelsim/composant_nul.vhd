library ieee;
use ieee.std_logic_1164.all;

    -- Ce composant met la valeur de led à celle de sw 
entity composant_nul is
    port (
        sw : in std_logic;
        led : out std_logic
    );
end entity composant_nul;

architecture rtl of composant_nul is
    
begin
    
    led <= sw;
    
end architecture rtl;

