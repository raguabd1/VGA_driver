
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is
    Port (
        dclk    : in  STD_LOGIC;   -- pixel clock: 25MHz
        clr     : in  STD_LOGIC;   -- asynchronous reset
        hsync   : out STD_LOGIC;   -- horizontal sync out
        vsync   : out STD_LOGIC;   -- vertical sync out
        red     : out STD_LOGIC_VECTOR(3 downto 0); -- red VGA output
        green   : out STD_LOGIC_VECTOR(3 downto 0); -- green VGA output
        blue    : out STD_LOGIC_VECTOR(3 downto 0)  -- blue VGA output
    );
end VGA;

architecture Behavioral of VGA is

    -- VGA timing parameters
    constant hpixels : integer := 1344;  -- horizontal pixels per line
    constant vlines  : integer := 806;  -- vertical lines per frame
    constant hpulse  : integer := 136;   -- hsync pulse length
    constant vpulse  : integer := 6;    -- vsync pulse length
    constant hbp     : integer := 1343;  -- end of horizontal back porch
    constant hfp     : integer := 1024;  -- beginning of horizontal front porch
    constant vbp     : integer := 805;   -- end of vertical back porch
    constant vfp     : integer := 771;  -- beginning of vertical front porch

    -- Signals for counting horizontal and vertical pixels/lines
    signal hc : integer range 0 to hpixels - 1 := 0;
    signal vc : integer range 0 to vlines - 1 := 0;

begin

    -- Process for counting horizontal and vertical pixels/lines
    process(dclk, clr)
    begin
        if clr = '1' then
            hc <= 0;
            vc <= 0;
        elsif rising_edge(dclk) then
            if hc < hpixels - 1 then
                hc <= hc + 1;
            else
                hc <= 0;
                if vc < vlines - 1 then
                    vc <= vc + 1;
                else
                    vc <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Process for setting VGA color output based on position
--    process(vc, hc)
    process(dclk)
    begin
     if clr = '1' then
            red <= "0000";
            green <= "0000";
            blue <= "0000"; -- Black colou
--        if ((vc >= 0 and vc < vfp) and (hc >= 0 and hc < 1024 )) then
       elsif rising_edge(dclk) then
        if ((hc >= 0 and hc < 1024 )) then
            if (hc >= 2 and hc < 350 ) then
             red <= "1111";
                green <= "0000";
                blue <= "0000"; 
             
            elsif (hc >= 351 and hc < 650) then
                red <= "0000";
                green <= "1111";
                blue <= "0000";   
            elsif (hc >= 651 and hc < 1022) then
                    red <= "0000";
                green <= "0000";
                blue <= "1111"; 
            end if;
         else
            red <= "0000";
            green <= "0000";
            blue <= "0000"; -- Black colour
        end if;
        end if;
    end process;

    -- Generate sync signals
    hsync <= '0' when (hc >= 1048 and hc <(1048+ hpulse)) else '1';
    vsync <= '0' when (vc >= 771 and vc < (771 +vpulse)) else '1';

end Behavioral;