CREATE TABLE IF NOT EXISTS `vehicles` (
  `name` varchar(60) NOT NULL,
  `model` varchar(50) NOT NULL DEFAULT '',
  `price` int(11) NOT NULL,
  `category` varchar(60) DEFAULT NULL,
  `shop` longtext DEFAULT NULL,
  PRIMARY KEY (`model`)
)

INSERT INTO `vehicles` (`name`, `model`, `price`, `category`, `shop`) VALUES
('Asbo','asbo',14000,'Compacts','["PDM"]'),
('Blista','blista',23000,'Compacts','["PDM"]'),
('Brioso R/A','brioso',27000,'Compacts','["PDM"]'),
('Club','club',15000,'Compacts','["PDM"]'),
('Dilettante','dilettante',13000,'Compacts','["PDM"]')

;
