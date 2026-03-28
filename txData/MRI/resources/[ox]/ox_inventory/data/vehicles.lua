return {
	-- 0	vehicle has no storage
	-- 1	vehicle has no trunk storage
	-- 2	vehicle has no glovebox storage
	-- 3	vehicle has trunk in the hood
	Storage = {
		[`jester`] = 3,
		[`adder`] = 3,
		[`osiris`] = 1,
		[`pfister811`] = 1,
		[`penetrator`] = 1,
		[`autarch`] = 1,
		[`bullet`] = 1,
		[`cheetah`] = 1,
		[`cyclone`] = 1,
		[`voltic`] = 1,
		[`reaper`] = 3,
		[`entityxf`] = 1,
		[`t20`] = 1,
		[`taipan`] = 1,
		[`tezeract`] = 1,
		[`torero`] = 3,
		[`turismor`] = 1,
		[`fmj`] = 1,
		[`infernus`] = 1,
		[`italigtb`] = 3,
		[`italigtb2`] = 3,
		[`nero2`] = 1,
		[`vacca`] = 3,
		[`vagner`] = 1,
		[`visione`] = 1,
		[`prototipo`] = 1,
		[`zentorno`] = 1,
		[`trophytruck`] = 0,
		[`trophytruck2`] = 0,
	},

	-- slots, maxWeight; default weight is 8000 per slot
	glovebox = {
		[0] = {5, 15000},		-- Compact
		[1] = {5, 15000},		-- Sedan
		[2] = {5, 15000},		-- SUV
		[3] = {5, 15000},		-- Coupe
		[4] = {5, 15000},		-- Muscle
		[5] = {5, 15000},		-- Sports Classic
		[6] = {5, 15000},		-- Sports
		[7] = {5, 15000},		-- Super
		[8] = {3, 3000},		-- Motorcycle
		[9] = {5, 15000},		-- Offroad
		[10] = {5, 15000},		-- Industrial
		[11] = {5, 15000},		-- Utility
		[12] = {5, 15000},		-- Van
		[14] = {5, 15000},	-- Boat
		[15] = {5, 15000},	-- Helicopter
		[16] = {5, 15000},	-- Plane
		[17] = {5, 15000},		-- Service
		[18] = {5, 15000},		-- Emergency
		[19] = {5, 15000},		-- Military
		[20] = {5, 15000},		-- Commercial (trucks)
		models = {
			[`panto`] = {3, 3000}
		}
	},

	trunk = {
		[0] = {5, 25000},		-- Compact
		[1] = {15, 25000},		-- Sedan
		[2] = {20, 25000},		-- SUV
		[3] = {7, 25000},		-- Coupe
		[4] = {7, 25000},		-- Muscle
		[5] = {7, 25000},		-- Sports Classic
		[6] = {5, 25000},		-- Sports
		[7] = {3, 25000},		-- Super
		[8] = {3, 15000},		-- Motorcycle
		[9] = {15, 25000},		-- Offroad
		[10] = {20, 25000},	-- Industrial
		[11] = {20, 25000},	-- Utility
		[12] = {20, 25000},	-- Van
		-- [14] -- Boat
		-- [15] -- Helicopter
		-- [16] -- Plane
		[17] = {5, 25000},	-- Service
		[18] = {5, 25000},	-- Emergency
		[19] = {5, 25000},	-- Military
		[20] = {25, 25000},	-- Commercial
		models = {
			[`panto`] = {3, 3000}
		},
	}
}
