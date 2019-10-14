-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Erstellungszeit: 14. Okt 2019 um 15:02
-- Server-Version: 5.5.60-0+deb8u1
-- PHP-Version: 5.6.33-0+deb8u1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `samp6840_samporg`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `AdminLog`
--

CREATE TABLE `AdminLog` (
  `id` int(255) NOT NULL,
  `Command` varchar(255) NOT NULL,
  `Admin` varchar(255) NOT NULL,
  `Target` varchar(255) NOT NULL,
  `Time` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Garages`
--

CREATE TABLE `Garages` (
  `id` int(255) NOT NULL,
  `GarageX` float(255,5) NOT NULL,
  `GarageY` float(255,5) NOT NULL,
  `GarageZ` float(255,5) NOT NULL,
  `SpawnX1` float(255,5) NOT NULL,
  `SpawnY1` float(255,5) NOT NULL,
  `SpawnZ1` float(255,5) NOT NULL,
  `SpawnA1` float(255,5) NOT NULL,
  `SpawnX2` float(255,5) NOT NULL,
  `SpawnY2` float(255,5) NOT NULL,
  `SpawnZ2` float(255,5) NOT NULL,
  `SpawnA2` float(255,5) NOT NULL,
  `SpawnX3` float(255,5) NOT NULL,
  `SpawnY3` float(255,5) NOT NULL,
  `SpawnZ3` float(255,5) NOT NULL,
  `SpawnA3` float(255,5) NOT NULL,
  `SpawnX4` float(255,5) NOT NULL,
  `SpawnY4` float(255,5) NOT NULL,
  `SpawnZ4` float(255,5) NOT NULL,
  `SpawnA4` float(255,5) NOT NULL,
  `Type` int(255) NOT NULL,
  `Name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Player`
--

CREATE TABLE `Player` (
  `id` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Salt` varchar(255) NOT NULL,
  `Adminlevel` int(255) NOT NULL,
  `Money` int(255) NOT NULL,
  `tBanned` int(255) NOT NULL,
  `tBanReason` varchar(255) NOT NULL,
  `tBanDate` varchar(255) NOT NULL,
  `tBannedBy` varchar(255) NOT NULL,
  `posX` float(255,5) NOT NULL,
  `posY` float(255,5) NOT NULL,
  `posZ` float(255,5) NOT NULL,
  `posA` float(255,5) NOT NULL,
  `fsID` int(255) NOT NULL,
  `Skin` int(255) NOT NULL,
  `FightStyle` int(255) NOT NULL,
  `Banned` int(11) NOT NULL,
  `tBanTime` int(11) NOT NULL,
  `BanReason` varchar(128) NOT NULL,
  `BanDate` varchar(128) NOT NULL,
  `BannedBy` varchar(24) NOT NULL,
  `Warns` int(11) NOT NULL,
  `Points` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `Player`
--

INSERT INTO `Player` (`id`, `Name`, `Password`, `Salt`, `Adminlevel`, `Money`, `tBanned`, `tBanReason`, `tBanDate`, `tBannedBy`, `posX`, `posY`, `posZ`, `posA`, `fsID`, `Skin`, `FightStyle`, `Banned`, `tBanTime`, `BanReason`, `BanDate`, `BannedBy`, `Warns`, `Points`) VALUES
(1, 'studs', 'AD2D5A3CFC8CBAB1AAFC238F70D4DC940AC68CAF8EC56A07EE699808A23A2B98', 'A356HpUF74715042uRP1S3p60', 0, 0, 0, '', '', '', -2018.19153, 253.96211, 32.45000, 34.87718, 0, 0, 0, 0, 0, '', '', '', 0, 569),
(2, 'taxiopfer', 'CB5C24DD1BFD2692FB9AFFE854A7D14DEDD4FA727002554D9CF19EFBC32C70F2', '548n068Dpsn7M7S6jnio06107', 0, 500, 0, '', '', '', -2007.12329, 233.52834, 30.03000, 349.95258, 1, 134, 15, 0, 0, '', '', '', 0, 175);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `PunishLog`
--

CREATE TABLE `PunishLog` (
  `id` int(255) NOT NULL,
  `Type` varchar(255) NOT NULL,
  `Target` varchar(255) NOT NULL,
  `Admin` varchar(255) NOT NULL,
  `Reason` varchar(255) NOT NULL,
  `Time` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `ServerCars`
--

CREATE TABLE `ServerCars` (
  `ListID` int(11) NOT NULL,
  `v_dbid` int(11) NOT NULL,
  `v_valid` int(11) NOT NULL,
  `v_color1` int(11) NOT NULL,
  `v_color2` int(11) NOT NULL,
  `v_function` int(11) NOT NULL,
  `v_cartype` int(11) NOT NULL,
  `v_PosX` float NOT NULL,
  `v_PosY` float NOT NULL,
  `v_PosZ` float NOT NULL,
  `v_PosR` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `ServerCars`
--

INSERT INTO `ServerCars` (`ListID`, `v_dbid`, `v_valid`, `v_color1`, `v_color2`, `v_function`, `v_cartype`, `v_PosX`, `v_PosY`, `v_PosZ`, `v_PosR`) VALUES
(12, 0, 1, 6, 0, 1, 420, -2007.8, 232.067, 28.4682, 349.66);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Vehicles`
--

CREATE TABLE `Vehicles` (
  `id` int(11) NOT NULL,
  `model` int(11) NOT NULL DEFAULT '0',
  `licenseplate` varchar(12) NOT NULL DEFAULT '',
  `kilometers` int(11) NOT NULL DEFAULT '0',
  `owner` int(11) NOT NULL DEFAULT '0',
  `tank` int(11) NOT NULL DEFAULT '0',
  `color1` int(11) NOT NULL DEFAULT '0',
  `color2` int(11) NOT NULL DEFAULT '0',
  `paintjob` int(11) NOT NULL DEFAULT '1337',
  `spoiler` int(11) NOT NULL DEFAULT '0',
  `hood` int(11) NOT NULL DEFAULT '0',
  `roof` int(11) NOT NULL DEFAULT '0',
  `sideskirt_left` int(11) NOT NULL DEFAULT '0',
  `sideskirt_right` int(11) NOT NULL DEFAULT '0',
  `nitro` int(11) NOT NULL DEFAULT '0',
  `lamps` int(11) NOT NULL DEFAULT '0',
  `exhaust` int(11) NOT NULL DEFAULT '0',
  `wheels` int(11) NOT NULL DEFAULT '0',
  `stereo` int(11) NOT NULL DEFAULT '0',
  `hydraulics` int(11) NOT NULL DEFAULT '0',
  `bullbar` int(11) NOT NULL DEFAULT '0',
  `bullbar_rear` int(11) NOT NULL DEFAULT '0',
  `bullbar_front` int(11) NOT NULL DEFAULT '0',
  `sign_front` int(11) NOT NULL DEFAULT '0',
  `bumper_front` int(11) NOT NULL DEFAULT '0',
  `bumper_rear` int(11) NOT NULL DEFAULT '0',
  `bullbars` int(11) NOT NULL DEFAULT '0',
  `vents` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `AdminLog`
--
ALTER TABLE `AdminLog`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `Garages`
--
ALTER TABLE `Garages`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `Player`
--
ALTER TABLE `Player`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `PunishLog`
--
ALTER TABLE `PunishLog`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `ServerCars`
--
ALTER TABLE `ServerCars`
  ADD PRIMARY KEY (`ListID`);

--
-- Indizes für die Tabelle `Vehicles`
--
ALTER TABLE `Vehicles`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `AdminLog`
--
ALTER TABLE `AdminLog`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `Garages`
--
ALTER TABLE `Garages`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `Player`
--
ALTER TABLE `Player`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT für Tabelle `PunishLog`
--
ALTER TABLE `PunishLog`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `ServerCars`
--
ALTER TABLE `ServerCars`
  MODIFY `ListID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT für Tabelle `Vehicles`
--
ALTER TABLE `Vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
