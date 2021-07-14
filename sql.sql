CREATE TABLE `player_veh` (
  `id` int(11) NOT NULL,
  `owner` longtext NOT NULL,
  `plate` longtext DEFAULT '0',
  `model` longtext DEFAULT NULL,
  `props` longtext DEFAULT NULL,
  `parked` int(11) DEFAULT '1',
  `label` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `player_veh`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `player_veh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
COMMIT;  