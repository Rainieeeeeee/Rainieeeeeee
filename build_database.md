connect to the cornell vpn

ssh rm2264@catserver.cee.cornell.edu

mysql -u writeinfo -p

SHOW DATABASES;

USE userdb;

CREATE TABLE greentech (     `Select Policy(ies)` VARCHAR(255),     `Policy ID` INT,     `CMAQ category (n = 7)` VARCHAR(255),     `EffectType` VARCHAR(255),     `Avg. Cost of Policy when applied 1 time/1
unit` DECIMAL(10, 2),     `MetricAffected` VARCHAR(255),     `Amount Activity Control` DECIMAL(10, 2),
 `Percent Activity Control (%)` DECIMAL(5, 2),     `Amount EF Control` DECIMAL(10, 2),     `Percent EF Control (%)` DECIMAL(5, 2),     `Standard Error` DECIMAL(10, 2) );

SHOW TABLES;

DESCRIBE greentech;

SELECT * FROM greentech;

SELECT  `Policy ID`, `CMAQ category (n = 7)`,`EffectType`, `Amount Activity Control`,`Amount EF Control`,`Standard Error` FROM greentech;
