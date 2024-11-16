LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.HDMI_PARAMETERS.ALL;

ENTITY video_source IS
PORT (
    din : IN rgb_t;
    clk : IN STD_LOGIC;
    video_en : IN STD_LOGIC;
    addr : OUT INTEGER RANGE 0 TO DISPLAY_RESOLUTION;
    channel_r, channel_g, channel_b : OUT byte
);
END ENTITY;

ARCHITECTURE rtl OF video_source IS
BEGIN
    PROCESS(clk)
        VARIABLE rom_addr : INTEGER RANGE 0 TO DISPLAY_RESOLUTION := 0;
    BEGIN
        IF(RISING_EDGE(clk)) THEN
            IF(video_en = '1') THEN
                IF(rom_addr = DISPLAY_RESOLUTION) THEN
                    rom_addr := 0;
                ELSE
                    rom_addr := rom_addr + 1;
                    addr <= rom_addr;
                    channel_b <= din(7 DOWNTO 0);
                    channel_g <= din(15 DOWNTO 8);
                    channel_r <= din(23 DOWNTO 16);
                END IF;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;