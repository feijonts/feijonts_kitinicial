CREATE TABLE IF NOT EXISTS `feijonts_kitinicial` (
  `user_id` int(11) NOT NULL DEFAULT 0,
  `collected` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;