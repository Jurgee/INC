-- uart.vhd: UART controller - receiving part
-- Author(s): Jiri Stipek
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
  CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
  signal cnt  : std_logic_vector(4 downto 0):= "00001";
  signal bcnt : std_logic_vector(3 downto 0):= "0000";
  signal en   : std_logic:= '0';
  signal cnt_out : std_logic:= '0';
  signal set0 : std_logic:= '0';
  signal valid : std_logic;
  begin
    
   FSM: entity work.UART_FSM(behavioral)
    port map (
        CLK 	    => CLK,
        RST 	    => RST,
        DIN 	    => DIN,
        CNT 	    => cnt, 
        BCNT     => bcnt,
        EN       => en,
        CNT_OUT  => cnt_out,
        DVALID => valid
        );
    
       process(CLK) begin
         if rising_edge(CLK) then 
          DOUT_VLD <= set0;
          
          if RST = '1' then --vynulovat vysledek
            DOUT <= "00000000";
          end if;
          
          if cnt_out = '1' then --zapnuto
            cnt <= cnt + "1";
          else
            cnt <= "00001";
          end if;
    
          if bcnt = "1000" then --8 bitu napocitano
            if valid = '1' then
            DOUT_VLD <= '1'; --vsechno v poradku
            bcnt <= "0000";
          end if;
        end if;
          if en = '1' then 
            if cnt(4) = '1' then
              cnt <= "00001";
              case bcnt is
              when "0000" => DOUT(0) <= DIN;
              when "0001" => DOUT(1) <= DIN;
              when "0010" => DOUT(2) <= DIN;
              when "0011" => DOUT(3) <= DIN;
              when "0100" => DOUT(4) <= DIN;
              when "0101" => DOUT(5) <= DIN;
              when "0110" => DOUT(6) <= DIN;
              when "0111" => DOUT(7) <= DIN;
              when others => null;
              end case;
 
              bcnt <= bcnt + "1";
            end if;
          end if;
        end if;
       end process;
end behavioral;
