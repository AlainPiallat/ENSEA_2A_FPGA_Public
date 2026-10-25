library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    generic (
        BUS_WIDTH : positive := 8
    );
    port (
        -- Input operands.
        data_in0 : in signed;
        data_in1 : in signed;

        -- Operation selector:
        -- 000 addition, 001 subtraction, 010 multiplication, 011 division,
        -- 100 OR, 101 AND, 110 XOR, and 111 bitwise NOT of data_in0.
        sel : in std_logic_vector(2 downto 0);

        -- Result of the selected operation.
        data_out : out signed
    );
end entity alu;

architecture rtl of alu is
begin
    data_out <= data_in0 + data_in1 when sel = "000" else 
                data_in0 - data_in1 when sel = "001" else
                resize(data_in0 * data_in1, 8) when sel = "010" else
                data_in0 / data_in1 when sel = "011" else
                data_in0 OR data_in1 when sel = "100" else
                data_in0 AND data_in1 when sel = "101" else
                data_in0 XOR data_in1 when sel = "110" else
                NOT data_in0 when sel = "111" else
                (data_out'range => 'U');
end architecture rtl;