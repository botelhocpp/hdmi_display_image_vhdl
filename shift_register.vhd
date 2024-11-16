LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY shift_register IS
GENERIC (N : INTEGER := 10);
PORT (
    din: IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    clk: IN STD_LOGIC;
    dout: OUT STD_LOGIC
);
END shift_register;

ARCHITECTURE behav OF shift_register IS
    SIGNAL data_bits : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
BEGIN
    PROCESS (clk)
        VARIABLE iterator : INTEGER RANGE 0 TO N := 0;
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            iterator := iterator + 1;
            
            IF (iterator = (N - 1)) THEN
                data_bits <= din;
            ELSIF (iterator = N) THEN
                iterator := 0;
            END IF;
            
            dout <= data_bits(iterator);
        END IF;
    END PROCESS;
END behav;
