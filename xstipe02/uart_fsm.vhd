-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): Jiri Stipek
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK : in std_logic;
   RST : in std_logic;
   DIN : in std_logic;
   CNT : in std_logic_vector(4 downto 0); --counter na 22
   BCNT : in std_logic_vector(3 downto 0); --counter na 8 bit
   EN : out std_logic; --odchod
   CNT_OUT : out std_logic; --odchod na pocitani 
   DVALID : out std_logic --data valid
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
  type Stype is (START, WAIT_FBIT, DATA, WAIT_SBIT, VALID);
  signal state : Stype:= START;
begin
  
  EN <= '1' when state = DATA else '0'; 
  DVALID <= '1' when state = VALID else '0';
  CNT_OUT <= '1' when state = WAIT_FBIT or state = DATA else '0';
  
process(CLK) begin
  if rising_edge(CLK) then
    if RST = '1' then --zaply reset
      state <= START;
    else
      case state is
        when START => if DIN = '0' then
                      state <= WAIT_FBIT; --cekej na prvni bit
                    end if;
        when WAIT_FBIT => if CNT = "10110" then --pocitej do 22
                          state <= DATA;
                        end if;
        when DATA => if BCNT = "1000" then --pocitej 8 bitu
                          state <= WAIT_SBIT;
                        end if;
        when WAIT_SBIT => if DIN = '1' then
                          state <= VALID;
                        end if;
        when VALID => state <= START;               
        when others => null;
      end case;
    end if;
  end if;
end process;
end behavioral;
