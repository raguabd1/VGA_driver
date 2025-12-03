library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity Declaration
entity dataGen is
    Port (
        i_clk        : in  STD_LOGIC; --input clock signal
        i_reset_n    : in  STD_LOGIC; --reset signal.
        o_data       : out STD_LOGIC_VECTOR(23 downto 0); --actual output data.
        o_data_valid : out STD_LOGIC; --output data valid
        i_data_ready : in  STD_LOGIC; --input ready port
        o_sof        : out STD_LOGIC; --start of frame
        o_eol        : out STD_LOGIC --end of line
    );
end dataGen;


architecture Behavioral of dataGen is

    -- Constants
    constant horSize   : integer := 1920;
    constant verSize    : integer :=1080;
    constant frameSize  : integer := 1920 * 1080; --Total clock cycles

    -- States
    type state_type is (IDLE, SEND_DATA, END_LINE);
    signal state        : state_type := IDLE;
    
    -- Signals for counters
    signal PixelCounter : integer range 0 to horSize-1 := 0; 
    signal LineCounter : integer range 0 to verSize-1 :=0;

begin
    -- Process to generate the output data
    process(i_clk, i_reset_n)
    begin
        if (i_reset_n = '0') then
            state               <= IDLE;
            PixelCounter    <= 0;
            LineCounter         <= 0;
            o_data_valid        <= '0';
            o_sof               <= '0';
            o_eol               <= '0';
        elsif rising_edge(i_clk) then
            case state is
                when IDLE =>
                    o_data_valid <= '0';  
     -- If slave is ready to accept data then only we should transit to send data state.  
                    if(i_data_ready = '1') then
                        state <= SEND_DATA;
                        o_data_valid <= '1';
                        o_sof <= '1';
                    end if;
                    
                    
                when SEND_DATA =>
                    if (i_data_ready = '1') then
                        o_sof <= '0';
                        PixelCounter <= PixelCounter + 1;
                        if (PixelCounter = horSize-2) then
                            o_eol <= '1'; --should be 1 during lineSize-1
                            state <= END_LINE;
                        end if;
                    end if;
                    
                    
                when END_LINE =>
                    if (i_data_ready = '1') then
                        o_eol <= '0';
                        PixelCounter <= 0;
                        LineCounter <= LineCounter + 1;
                         if (LineCounter = verSize - 1) then
                             state <= IDLE;
                             o_data_valid <= '0';
                             LineCounter <= 0;
                         else state <= SEND_DATA;
                         end if;
                   end if;
            end case;
        end if;
    end process;

    -- Assign output data based on linePixelCounter
    process(PixelCounter)
    begin
        if (PixelCounter >= 0 and PixelCounter < 640) then
            o_data <= x"0000FF";  -- Blue color
        elsif (PixelCounter >= 640 and PixelCounter < 1280) then
            o_data <= x"00FF00";  -- Green color
        else
            o_data <= x"FF0000";  -- Red color
        end if;
    end process;

end Behavioral;

