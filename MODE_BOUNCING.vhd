-- MODE_BOUNCING.VHDL


LIBRARY IEEE;
--LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.all;
--USE IEEE.STD_LOGIC_1164.ALL;
-- Copied these below from LED Controller
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE LPM.LPM_COMPONENTS.ALL;

-- Just copied HEX_DISP Vhdl just for reference

ENTITY MODE_BOUNCING IS
  PORT( 
		  CurrentPattern: IN STD_LOGIC_VECTOR(9 DOWNTO 0);     -- What is the current LED value. feel like this should be a signal
		  AC_Value  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);    -- if AC is 0, it will bounce left first, if AC is 1, will bounce right?, what value does AC have to do with the bouncing
																			-- should it be the level of smoothness???
																			-- on a range of 0 to 2^16																		
        cs        : IN STD_LOGIC := '0'; 					   -- chip select
--        free      : IN STD_LOGIC := '0'; 					-- Look back in HEX_DISP, I think this is helpful for doing ins and outs to the same peripheral
        resetn    : IN STD_LOGIC := '1'; 						-- reset is active low, why do we initialize it to high?
        LEDOutput : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);  -- doing 9-0 because there are only 10 LEDs
		  CLOCK 		: IN STD_LOGIC);
END MODE_BOUNCING;

ARCHITECTURE a OF MODE_BOUNCING IS

	-- Tbh, you don't really need all that just to get the pattern to stay still I don't think
--  SIGNAL latched_hex : STD_LOGIC_VECTOR(3 DOWNTO 0);
--  SIGNAL hex_d       : STD_LOGIC_VECTOR(3 DOWNTO 0);

-- Okay another issue I'm having is the fact if we want to mix speed, brightness, and bouncing
-- if the output is always going to go to the LEDs (physically wired),
-- should we have another peripheral that takes all of the modes together and merges them
-- how what that even look like
-- I can see making the bouncing pattern by itself in hardware
-- But I can't see how to make the LEDs bounce while simultaneously executing other instructions
-- Should AC then be how many times the LEDs should bounce, with like a for loop but HW?
-- If only one peripheral can be working at a time, how do you make a mix between them all?

	signal count : integer;
	signal CurrentLED: STD_LOGIC_VECTOR(9 DOWNTO 0); 
	signal end_idx: integer := 8; 
	signal start_idx : integer := 0; 
	signal direction: integer := 0; -- 0 for right shift and 1 for left shift
	
	constant zero : STD_LOGIC_VECTOR(9 downto 0);

BEGIN
	-- To be honest I don't even need AC_Value
--  PROCESS (resetn, cs, CLOCK)
--  BEGIN
--    IF (resetn = '0') THEN
--      LEDOutput <= "0000000000";
--		count <= 0;
--    ELSIF ( RISING_EDGE(cs) ) THEN -- This is saying that if Chip Select goes from low to high 
--	 -- Then make the LEDOutput the CurrentLED
--		
--      LEDOutput <= CurrentLED; -- This assumes CurrentLED is correct
--		
--		-- use a counter to keep track of time
--		IF rising_edge(CLOCK) THEN
--			count <= count + 1;
--			IF count == 50000000 THEN
--				count <= 0; -- count 50000000 ticks of the clock and reset the counter
--				IF direction == '0' THEN
--					CurrentLED <=  zero(9-end_idx downto 0) & CurrentLED(end_idx downto 0); -- right shift
--					end_idx <= end_idx - 1;
--				ELSE
--					CurrentLED <= zero(9 downto start_idx) & CurrentLED(start_idx downto 0) & '0'; -- left shift if direction is 1
--					start_idx  <= start_idx + 1;
--				END IF;
--				
--				IF end_idx < 0 THEN -- shift 9 times in either direction? this is a placeholder
--						direction = '1';
--
--				ELSIF start_idx == 9:
--						direction = '0';
--				
--				END IF;
--				LEDOutput <= CurrentLED;
--			END IF;
--    END IF;
--  END PROCESS;
PROCESS (resetn, cs, CLOCK)
BEGIN
    IF (resetn = '0') THEN
        LEDOutput <= "0000000000";
        count <= 0;
    ELSIF (RISING_EDGE(cs)) THEN
        -- This assumes CurrentLED is correct
        LEDOutput <= CurrentLED;

        -- Use a counter to keep track of time
        IF rising_edge(CLOCK) THEN
            count <= count + 1;
            IF count = 50000000 THEN
                count <= 0; -- Reset the counter after 50000000 ticks

                -- Temporary variable to hold the shifted pattern
                

                IF direction = 0 THEN
                    -- Right shift logic
                    LEDOutput <= zero(9 - end_idx DOWNTO 0) & CurrentLED(end_idx DOWNTO 0);
                    end_idx <= end_idx - 1;
                ELSE
                    -- Left shift logic
                    LEDOutput <= zero(9 DOWNTO start_idx) & CurrentLED(start_idx DOWNTO 0) & '0';
                    start_idx <= start_idx + 1;
                END IF;
                -- Update CurrentLED with the shifted pattern
                CurrentLED <= shifted_pattern;

                -- Check for direction change
                IF end_idx < 0 THEN
                    direction <= 1;  -- Change direction to left shift
                ELSIF start_idx = 9 THEN
                    direction <= 0;  -- Change direction to right shift
                END IF;

                -- Update LED output
                LEDOutput <= CurrentLED;
            END IF;
        END IF;
    END IF;
END PROCESS;
  
END a;

