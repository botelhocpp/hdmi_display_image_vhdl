LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.HDMI_PARAMETERS.ALL;

ENTITY tmds_encoder IS
PORT(  
    data : IN byte;
	clk : IN STD_LOGIC;
    vde : IN STD_LOGIC; 
    c1, c0 : IN STD_LOGIC := '0';
    q_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE rtl OF tmds_encoder IS
  SIGNAL disparity : INTEGER RANGE -16 TO 15 := 0;
  SIGNAL control : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  
  -- Intermediary data
  SIGNAL q_m : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0'); 
  
  -- Number of ones in the input data and in intermediary data
  SIGNAL ones_data : INTEGER RANGE 0 TO 8 := 0; 
  SIGNAL ones_q_m : INTEGER RANGE 0 TO 8 := 0;
  
  -- Number of ones minus the number of zeros in the intermediary data
  SIGNAL diff_q_m : INTEGER RANGE -8 TO 8 := 0; 
BEGIN
  -- Count the ones in the input data byte
  PROCESS(data)
    VARIABLE ones : INTEGER RANGE 0 TO 8 := 0;
  BEGIN
    ones := 0;
    FOR i IN data'RANGE LOOP
      IF(data(i) = '1') THEN
        ones := ones + 1;
      END IF;
    END LOOP;
    ones_data <= ones;
  END PROCESS;

  -- Process intermediary data to minimize transitions
  PROCESS(data, q_m, ones_data)
  BEGIN
    IF(ones_data > 4 OR (ones_data = 4 AND data(0) = '0')) THEN
      q_m(0) <= data(0);
      q_m(1) <= q_m(0) XNOR data(1);
      q_m(2) <= q_m(1) XNOR data(2);
      q_m(3) <= q_m(2) XNOR data(3);
      q_m(4) <= q_m(3) XNOR data(4);
      q_m(5) <= q_m(4) XNOR data(5);
      q_m(6) <= q_m(5) XNOR data(6);
      q_m(7) <= q_m(6) XNOR data(7);
      q_m(8) <= '0';
    ELSE
      q_m(0) <= data(0);
      q_m(1) <= q_m(0) XOR data(1);
      q_m(2) <= q_m(1) XOR data(2);
      q_m(3) <= q_m(2) XOR data(3);
      q_m(4) <= q_m(3) XOR data(4);
      q_m(5) <= q_m(4) XOR data(5);
      q_m(6) <= q_m(5) XOR data(6);
      q_m(7) <= q_m(6) XOR data(7);
      q_m(8) <= '1';
    END IF;
  END PROCESS;
  
  -- Count the ones in the intermediary data
  PROCESS(q_m)
    VARIABLE ones : INTEGER RANGE 0 TO 8 := 0;
  BEGIN
    ones := 0;
    FOR i IN 0 TO 7 LOOP
      IF(q_m(i) = '1') THEN
        ones := ones + 1;
      END IF;
    END LOOP;
    ones_q_m <= ones;
    diff_q_m <= ones + ones - 8;  -- Difference between the number of ones and zeros
  END PROCESS;
  
  -- Determine output and new disparity
  PROCESS(clk)
  BEGIN
    IF(RISING_EDGE(clk)) THEN
	  -- Send Data
      IF(vde = '1') THEN  
        IF(disparity = 0 OR ones_q_m = 4) THEN
          IF(q_m(8) = '0') THEN
            q_out <= NOT q_m(8) & q_m(8) & NOT q_m(7 DOWNTO 0);
            disparity <= disparity - diff_q_m;
          ELSE
            q_out <= NOT q_m(8)& q_m(8 DOWNTO 0);
            disparity <= disparity + diff_q_m;
          END IF;
        ELSE
          IF((disparity > 0 AND ones_q_m > 4) OR (disparity < 0 AND ones_q_m < 4)) THEN
            q_out <= '1' & q_m(8) & NOT q_m(7 DOWNTO 0);
            IF(q_m(8) = '0') THEN
              disparity <= disparity - diff_q_m;
            ELSE
              disparity <= disparity - diff_q_m + 2;
            END IF;
          ELSE
            q_out <= '0' & q_m(8 DOWNTO 0);
            IF(q_m(8) = '0') THEN
              disparity <= disparity + diff_q_m - 2;
            ELSE
              disparity <= disparity + diff_q_m;
            END IF;
          END IF;
        END IF;
      ELSE
	    -- Send Control
        CASE control IS
          WHEN "00" => q_out <= "1101010100";
          WHEN "01" => q_out <= "0010101011";
          WHEN "10" => q_out <= "0101010100";
          WHEN "11" => q_out <= "1010101011";
          WHEN OTHERS => NULL;
        END CASE;
        disparity <= 0;
      END IF;
    END IF;
  END PROCESS;
  
  control <= c1 & c0;
END ARCHITECTURE;