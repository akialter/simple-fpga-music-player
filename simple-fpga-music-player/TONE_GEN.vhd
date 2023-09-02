-- Simple DDS tone generator.
-- 5-bit tuning word
-- 9-bit phase register
-- 256 x 8-bit ROM.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY ALTERA_MF;
USE ALTERA_MF.ALTERA_MF_COMPONENTS.ALL;


ENTITY TONE_GEN IS 
	PORT
	(
		CMD        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		BEEP_EN    : IN  STD_LOGIC;
		WAVE_EN	  : IN  STD_LOGIC;
		VOLUME_EN  : IN  STD_LOGIC;
		SAMPLE_CLK : IN  STD_LOGIC;
		RESETN     : IN  STD_LOGIC;
		L_DATA     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		R_DATA     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END TONE_GEN;

ARCHITECTURE gen OF TONE_GEN IS 
	
	TYPE t_vector is array (0 to 12) of STD_LOGIC_VECTOR(13 DOWNTO 0);
	SIGNAL arr 				 : t_vector;
	SIGNAL phase_register : STD_LOGIC_VECTOR(13 DOWNTO 0);
	SIGNAL tuning_word    : STD_LOGIC_VECTOR(13 DOWNTO 0);
	SIGNAL sounddata      : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL sounddata2	 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL sounddata3	 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL sounddata4  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	TYPE state_type IS (state1, state2, state3, state4);
	TYPE state_volume_type IS (zero, one, two, three, none, ntwo, nthree);
	TYPE state_wave_type IS (sine, square, triangle);
	SIGNAL state 			 : state_type;
	SIGNAL state_volume   : state_volume_type;
	SIGNAL state_wave		 : state_wave_type;
	SIGNAL sounddata_sine : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL sounddata_sq   : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL sounddata_tri  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
BEGIN

	-- ROM to hold the sine waveform
	SOUND_LUT_SINE : altsyncram
	GENERIC MAP (
		lpm_type => "altsyncram",
		width_a => 8,
		widthad_a => 13,
		numwords_a => 8192,
		init_file => "sine.mif",
		intended_device_family => "Cyclone II",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		power_up_uninitialized => "FALSE"	
	)
	PORT MAP (
		clock0 => NOT(SAMPLE_CLK),
		-- In this design, one bit of the phase register is a fractional bit
		address_a => phase_register(12 downto 0),
		q_a => sounddata_sine -- output is amplitude
	);
	
	-- ROM to hold the square waveform
	SOUND_LUT_SQUARE : altsyncram
	GENERIC MAP (
		lpm_type => "altsyncram",
		width_a => 8,
		widthad_a => 13,
		numwords_a => 8192,
		init_file => "square.mif",
		intended_device_family => "Cyclone II",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		power_up_uninitialized => "FALSE"	
	)
	PORT MAP (
		clock0 => NOT(SAMPLE_CLK),
		-- In this design, one bit of the phase register is a fractional bit
		address_a => phase_register(12 downto 0),
		q_a => sounddata_sq -- output is amplitude
	);
	
	-- ROM to hold the triangle waveform
	SOUND_LUT_TRIANGLE : altsyncram
	GENERIC MAP (
		lpm_type => "altsyncram",
		width_a => 8,
		widthad_a => 13,
		numwords_a => 8192,
		init_file => "triangle.mif",
		intended_device_family => "Cyclone II",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		power_up_uninitialized => "FALSE"	
	)
	PORT MAP (
		clock0 => NOT(SAMPLE_CLK),
		-- In this design, one bit of the phase register is a fractional bit
		address_a => phase_register(12 downto 0),
		q_a => sounddata_tri -- output is amplitude
	);
	
	
	-- Update sounddata to correct waveform depending on state
	with state_wave select sounddata <=
		sounddata_sine when sine,
		sounddata_sq when square,
		sounddata_tri when triangle;
	
	-- Negates value of sounddata if in latter half of wave to allow quarter-wave symmetry
	with state select sounddata2 <= 
		sounddata when state1,
		sounddata when state2,
		not(sounddata) + 1 when state3,
		not(sounddata) + 1 when state4;
	
	-- Pad sounddata with 0s and sign extends to the left
	sounddata3(15 DOWNTO 13) <= sounddata2(7)&sounddata2(7)&sounddata2(7);
	sounddata3(12 DOWNTO 5) <= sounddata2;
	sounddata3(4 DOWNTO 0) <= "00000";
	
	-- Sets volume of sounddata accordingly by left or right shifting
	with state_volume select sounddata4 <=
		SHL(sounddata3, "1") when one,
		SHL(sounddata3, "10") when two,
		SHL(sounddata3, "11") when three,
		sounddata3(15) & SHR(sounddata3, "1")(14 DOWNTO 0) when none,
		sounddata3(15) & sounddata3(15) & SHR(sounddata3, "10")(13 DOWNTO 0) when ntwo,
		sounddata3(15) & sounddata3(15) & sounddata3(15) & SHR(sounddata3, "11")(12 DOWNTO 0) when nthree,
		sounddata3 when zero;
	
	-- Sends final sounddata to speaker peripheral
	L_DATA <= sounddata4;
	R_DATA <= sounddata4;
	
	-- Set array values for each tuning word
	arr(0)  <= "00000000000000"; -- stop
	arr(1)  <= "00000001000111"; -- G# => 71
	arr(2)  <= "00000001001011"; -- A => 75
	arr(3)  <= "00000001010000"; -- A# => 80
	arr(4)  <= "00000001010100"; -- B => 84
	arr(5)  <= "00000000101101"; -- C => 45
	arr(6)  <= "00000000101111"; -- C# => 47
	arr(7)  <= "00000000110010"; -- D => 50
	arr(8)  <= "00000000110101"; -- D# => 53
	arr(9)  <= "00000000111000"; -- E => 56
	arr(10) <= "00000000111100"; -- F => 60
	arr(11) <= "00000000111111"; -- F# => 63
	arr(12) <= "00000001000011"; -- G => 67
	
	
	-- Process to iterate through the waveform using the tuning word to produce specific frequencies
	PROCESS(RESETN, SAMPLE_CLK) BEGIN
		IF RESETN = '0' THEN
			phase_register <= "00000000000000";
			state <= state1;
		ELSIF RISING_EDGE(SAMPLE_CLK) THEN
			IF tuning_word = "00000" THEN  -- if command is 0, return to 0 output.
				phase_register <= "00000000000000";
			ELSE
				-- increments phase register forwards or backwards depending on state to allow for quarter-wave symmetry
				CASE state IS
					WHEN state1 =>
						phase_register <= phase_register + tuning_word;
					WHEN state2 =>
						phase_register <= phase_register - tuning_word;
					WHEN state3 =>
						phase_register <= phase_register + tuning_word;
					WHEN state4 =>
						phase_register <= phase_register - tuning_word;
				END CASE;
				
				-- detects when phase register hits the end of the current rom and adjusts its address and state
				IF phase_register(13) = '1' THEN
					CASE state IS
						WHEN state1 =>
							phase_register <= "01111111111111" - ('0' & phase_register(12 downto 0));
							state <= state2;
						WHEN state2 =>
							phase_register <= "00000000000000" - phase_register;
							state <= state3;
						WHEN state3 =>
							phase_register <= "01111111111111" - ('0' & phase_register(12 downto 0));
							state <= state4;
						WHEN state4 =>
							phase_register <= "00000000000000" - phase_register;
							state <= state1;
					END CASE;
				END IF;
			END IF;
		END IF;
	END PROCESS;

	-- Process to detect when sound address has been outted to and sets the tuning word
	-- accordingly to what is latched on SCOMP.
	PROCESS(RESETN, BEEP_EN) BEGIN
		IF RESETN = '0' THEN
			tuning_word <= "00000000000000";
		ELSIF RISING_EDGE(BEEP_EN) THEN
			tuning_word <= SHL(arr(conv_integer(CMD(3 DOWNTO 0))), CMD(6 DOWNTO 4));
		END IF;
	END PROCESS;
	
	-- Process to detect when volume address has been outted to and sets the state
	-- of the volume accordingly.
	-- Latches command data from SCOMP to decide which volume to set.
	PROCESS(RESETN, VOLUME_EN) BEGIN
		IF RESETN = '0' THEN
			state_volume <= zero;
		ELSIF RISING_EDGE(VOLUME_EN) THEN
			IF CMD(6 DOWNTO 0) = "0000001" THEN
				state_volume <= three;
			ELSIF CMD(6 DOWNTO 0) = "0000010" THEN
				state_volume <= two;
			ELSIF CMD(6 DOWNTO 0) = "0000100" THEN
				state_volume <= one;
			ELSIF CMD(6 DOWNTO 0) = "1000000" THEN
				state_volume <= nthree;
			ELSIF CMD(6 DOWNTO 0) = "0010000" THEN
				state_volume <= none;
			ELSIF CMD(6 DOWNTO 0) = "0100000" THEN
				state_volume <= ntwo;
			ELSE
				state_volume <= zero;
			END IF;
		END IF;
	END PROCESS;
	
	-- Process to detect when wave address has been outted to and sets the state
	-- of the waveform accordingly.
	-- Latches command data from SCOMP to decide which waveform to set.
	PROCESS(RESETN, WAVE_EN) BEGIN
		IF RESETN = '0' THEN
			state_wave <= sine;
		ELSIF RISING_EDGE(WAVE_EN) THEN
			IF CMD(2 DOWNTO 0) = "001" THEN
				state_wave <= sine;
			ELSIF CMD(2 DOWNTo 0) = "010" THEN
				state_wave <= square;
			ELSIF CMD(2 DOWNTO 0) = "100" THEN
				state_wave <= triangle;
			ELSE
				state_wave <= sine;
			END IF;
		END IF;
	END PROCESS;
	
END gen;