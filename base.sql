DROP TABLE IF EXISTS `snapshot`;
CREATE TABLE `snapshot` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `host` varchar(100) NOT NULL,
  `vm` varchar(100) NOT NULL,
  `action` varchar(100) NOT NULL,
  `snapshot` varchar(100) NOT NULL,
  `status` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
