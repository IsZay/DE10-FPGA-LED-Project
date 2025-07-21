-- LED_Controller.VHD (a peripheral module for SCOMP)
-- 2025.3.31
--
-- LED Controller allows the user to set the LED pattern, animation mode, and brightness
-- Currently patterns and brightness control with gamma correction have been implemented

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE LPM.LPM_COMPONENTS.ALL;


ENTITY LED_CONTROLLER IS
	PORT(CLOCK,
		RESETN,
		PATTERN_EN,
		MODE_EN,
		BRIGHTNESS_EN,
		WRITE_EN : IN  STD_LOGIC;
		IO_DATA  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		LEDs :     OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END LED_CONTROLLER;


ARCHITECTURE a OF LED_CONTROLLER IS
	signal pattern:    std_logic_vector(9 downto 0);
	signal output_pattern:    std_logic_vector(9 downto 0);
	signal mode:       std_logic_vector(2 downto 0);
	signal brightness: integer range 0 to 100;
	signal gamma:      integer range 0 to 100;
	signal count:      integer range 0 to 101;
	signal animation_counter: integer range 0 to 12000000;
	signal animation_index:   integer range 0 to 100;
BEGIN
	-- register maps
	process (resetn, PATTERN_EN)
	begin
		if (resetn = '0') then
			pattern <= "0000000000"; -- all leds off
		elsif (rising_edge(PATTERN_EN)) then
			if (WRITE_EN = '1') then
				pattern <= IO_DATA(9 downto 0);
			end if;
		end if;
	end process;
	
	process (resetn, MODE_EN)
	begin
		if (resetn = '0') then
			mode <= "000"; -- mode 0
		elsif (rising_edge(MODE_EN)) then
			if (WRITE_EN = '1') then
				mode <= IO_DATA(2 downto 0);
			end if;
		end if;
	end process;
	
	process (resetn, BRIGHTNESS_EN)
	begin
		if (resetn = '0') then
			brightness <= 50; -- 50% brightness by default
		elsif (rising_edge(BRIGHTNESS_EN)) then
			if (WRITE_EN = '1') then
				brightness <= to_integer(unsigned(IO_DATA(6 downto 0)));
				if (brightness > 100) then
					brightness <= 100;
				end if;
			end if;
		end if;
	end process;

	-- pwm counter
	process (resetn, clock)
	begin
		if (resetn = '0') then
			count <= 0;
			animation_index <= 0;
			animation_counter <= 0;
		elsif (rising_edge(clock)) then
			count <= count + 1;
			animation_counter <= animation_counter + 1;
			if (count > 100) then
				count <= 0;
			end if;
			if (animation_counter = 12000000) then
				animation_counter <= 0;
				animation_index <= animation_index + 1;
			end if;	
			case mode is
				when "000" => -- static
					output_pattern <= pattern;
					animation_index <= 0;
				when "001" => -- blink
					if animation_index > 1 then
						animation_index <= 0;
					end if;
					
					if animation_index = 1 then
						output_pattern <= pattern;
					else 
						output_pattern <= "0000000000";
					end if;
				when others => -- bounce
					if animation_index < 10 then
						output_pattern <= std_logic_vector(unsigned(pattern) sll animation_index) or std_logic_vector(unsigned(pattern) srl (10 - animation_index));
					else
						output_pattern <=  std_logic_vector(unsigned(pattern) sll (18 - animation_index)) or std_logic_vector(unsigned(pattern) srl (10 - (18 - animation_index)));
					end if;
					if animation_index = 18 then
						animation_index <= 0;
						output_pattern <= pattern;
					end if;
			end case;
		end if;
	end process;


			
	-- output logic
	LEDs <= output_pattern when (count < gamma + 1) else "0000000000";
	
	-- gamma correction table (computer generated code)
	gamma <= 
		0 when brightness = 0 else
		0 when brightness = 1 else
		0 when brightness = 2 else
		0 when brightness = 3 else
		0 when brightness = 4 else
		0 when brightness = 5 else
		0 when brightness = 6 else
		0 when brightness = 7 else
		0 when brightness = 8 else
		0 when brightness = 9 else
		0 when brightness = 10 else
		0 when brightness = 11 else
		0 when brightness = 12 else
		0 when brightness = 13 else
		0 when brightness = 14 else
		0 when brightness = 15 else
		0 when brightness = 16 else
		0 when brightness = 17 else
		0 when brightness = 18 else
		0 when brightness = 19 else
		1 when brightness = 20 else
		1 when brightness = 21 else
		1 when brightness = 22 else
		1 when brightness = 23 else
		1 when brightness = 24 else
		1 when brightness = 25 else
		2 when brightness = 26 else
		2 when brightness = 27 else
		2 when brightness = 28 else
		3 when brightness = 29 else
		3 when brightness = 30 else
		3 when brightness = 31 else
		3 when brightness = 32 else
		4 when brightness = 33 else
		4 when brightness = 34 else
		5 when brightness = 35 else
		5 when brightness = 36 else
		6 when brightness = 37 else
		6 when brightness = 38 else
		7 when brightness = 39 else
		7 when brightness = 40 else
		8 when brightness = 41 else
		8 when brightness = 42 else
		9 when brightness = 43 else
		9 when brightness = 44 else
		10 when brightness = 45 else
		11 when brightness = 46 else
		11 when brightness = 47 else
		12 when brightness = 48 else
		13 when brightness = 49 else
		14 when brightness = 50 else
		15 when brightness = 51 else
		15 when brightness = 52 else
		16 when brightness = 53 else
		17 when brightness = 54 else
		18 when brightness = 55 else
		19 when brightness = 56 else
		20 when brightness = 57 else
		21 when brightness = 58 else
		22 when brightness = 59 else
		23 when brightness = 60 else
		24 when brightness = 61 else
		26 when brightness = 62 else
		27 when brightness = 63 else
		28 when brightness = 64 else
		29 when brightness = 65 else
		30 when brightness = 66 else
		32 when brightness = 67 else
		33 when brightness = 68 else
		34 when brightness = 69 else
		36 when brightness = 70 else
		38 when brightness = 71 else
		39 when brightness = 72 else
		41 when brightness = 73 else
		42 when brightness = 74 else
		44 when brightness = 75 else
		45 when brightness = 76 else
		47 when brightness = 77 else
		49 when brightness = 78 else
		51 when brightness = 79 else
		53 when brightness = 80 else
		54 when brightness = 81 else
		57 when brightness = 82 else
		58 when brightness = 83 else
		61 when brightness = 84 else
		62 when brightness = 85 else
		65 when brightness = 86 else
		67 when brightness = 87 else
		69 when brightness = 88 else
		71 when brightness = 89 else
		74 when brightness = 90 else
		76 when brightness = 91 else
		78 when brightness = 92 else
		81 when brightness = 93 else
		83 when brightness = 94 else
		86 when brightness = 95 else
		88 when brightness = 96 else
		91 when brightness = 97 else
		93 when brightness = 98 else
		96 when brightness = 99 else 100;
END a;
