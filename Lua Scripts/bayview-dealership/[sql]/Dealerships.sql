CREATE TABLE IF NOT EXISTS `vehicles` (
  `name` varchar(60) NOT NULL,
  `model` varchar(50) NOT NULL DEFAULT '',
  `price` int(11) NOT NULL,
  `category` varchar(60) DEFAULT NULL,
  `shop` longtext DEFAULT NULL,
  PRIMARY KEY (`model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicle_shops` (
  `owner` varchar(100) NOT NULL,
  `name` varchar(50) NOT NULL,
  `locations` longtext NOT NULL,
  `employees` longtext NOT NULL,
  `stock` longtext NOT NULL,
  `displays` longtext NOT NULL,
  `funds` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `warehouse` tinyint(1) NOT NULL DEFAULT 1,
  `blipdetails` longtext NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `vehicle_shops` (`owner`, `name`, `locations`, `employees`, `stock`, `displays`, `funds`, `price`, `warehouse`, `blipdetails`) VALUES
	('KEU02802', 'PDM', '{"purchased":{"y":-1075.360595703125,"z":27.04184341430664,"heading":70.64143371582031,"x":-48.14004516601562},"management":{"y":-1097.7672119140626,"z":27.27439880371093,"x":-31.035005569458},"deposit":{"y":-1086.06591796875,"z":27.04219436645507,"x":-13.59219646453857},"blip":{"y":-1101.9561767578126,"z":27.27434921264648,"x":-27.18266487121582},"entry":{"y":-1102.8372802734376,"z":27.27465057373047,"x":-47.05863189697265},"spawn":{"y":-1095.864501953125,"z":27.27445602416992,"heading":70.75979614257813,"x":-42.59846115112305}}', '{}', '{}', '{"2WT276OW":{"vehicle":{"modCustomTiresF":false,"modBackWheels":-1,"modHorns":-1,"modDial":-1,"modBrakes":-1,"modLivery":-1,"modEngine":-1,"modXenon":false,"wheelWidth":1.0,"fuelLevel":96.11371640163806,"modTrimB":-1,"modSmokeEnabled":false,"modKit17":-1,"wheels":1,"modCustomTiresR":false,"modTrimA":-1,"modPlateHolder":-1,"headlightColor":255,"extras":[],"modTrunk":-1,"dirtLevel":3.17731293889712,"modDashboard":-1,"engineHealth":1000.0592475178704,"modStruts":-1,"modFrontWheels":-1,"modShifterLeavers":-1,"modWindows":-1,"modSideSkirt":-1,"modExhaust":-1,"windowStatus":{"1":true,"2":true,"3":true,"4":false,"5":false,"6":true,"7":true,"0":true},"modGrille":-1,"modRoof":-1,"modHydrolic":-1,"modRightFender":-1,"modTurbo":false,"plateIndex":0,"liveryRoof":-1,"tankHealth":1000.0592475178704,"tireBurstState":{"1":false,"2":false,"3":false,"4":false,"5":false,"0":false,"47":false,"45":false},"modArchCover":-1,"modTransmission":-1,"tireBurstCompletely":{"1":false,"2":false,"3":false,"4":false,"5":false,"0":false,"47":false,"45":false},"modArmor":-1,"modFender":-1,"bodyHealth":1000.0592475178704,"neonColor":[255,0,255],"tyreSmokeColor":[255,255,255],"model":-2122646867,"modEngineBlock":-1,"doorStatus":{"1":false,"2":false,"3":false,"4":false,"5":false,"0":false},"modVanityPlate":-1,"modKit19":-1,"modSteeringWheel":-1,"modSpoilers":-1,"modHood":-1,"pearlescentColor":134,"wheelSize":1.0,"modKit49":-1,"modFrontBumper":-1,"modDrift":false,"modOrnaments":-1,"tireHealth":{"1":1000.0,"2":1000.0,"3":1000.0,"4":0.0,"5":0.0,"0":1000.0,"47":0.0,"45":0.0},"dashboardColor":111,"plate":"2WT276OW","modSuspension":-1,"modKit21":-1,"modSpeakers":-1,"modBProofTires":false,"modKit47":-1,"modAPlate":-1,"oilLevel":4.76596940834568,"modSeats":-1,"modDoorSpeaker":-1,"interiorColor":13,"neonEnabled":[false,false,false,false],"modTank":-1,"modAirFilter":-1,"modAerials":-1,"wheelColor":13,"color2":13,"color1":0,"modRearBumper":-1,"windowTint":-1,"modFrame":-1},"location":{"y":-1093.4293212890626,"heading":107.25982666015625,"x":-36.3919448852539,"z":26.66958618164062}}}', 9855998, 1, 1, '{"scale":1.0,"color":0,"sprite":225}');
