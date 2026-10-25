library ieee;
use IEEE.std_logic_1164.all;

entity decoder is
    port (
        data_in : in std_logic_vector(1 downto 0);
        data_out : out std_logic_vector(3 downto 0)
    );
end entity decoder;

architecture rtl of decoder is
    
begin
    data_out <= "0001" when data_in = "00" else
                "0010" when data_in = "01" else 
                "0100" when data_in = "10" else 
                "1000" when data_in = "11" else
                "UUUU";
end architecture rtl;

