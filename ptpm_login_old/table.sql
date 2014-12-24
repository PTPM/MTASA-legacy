CREATE TABLE  `logindata` (
 `username` VARCHAR( 40 ) NOT NULL ,
 `password` CHAR( 32 ) NOT NULL ,
 `serial` CHAR( 32 ) NOT NULL ,
 `passlen` TINYINT NOT NULL ,
 `save` BINARY NOT NULL ,
INDEX (  `username` )
) ENGINE = MYISAM ;