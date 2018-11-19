--create table REG_CLUSTER_LOCK
if not exists (select * from sysobjects where id = object_id('REG_CLUSTER_LOCK') and type in ('U'))
execute("create table  REG_CLUSTER_LOCK (
	REG_LOCK_NAME varchar (20) NOT NULL,
	REG_LOCK_STATUS varchar (20),
	REG_LOCKED_TIME datetime,
	REG_TENANT_ID integer default 0 NOT NULL,
	primary key (REG_LOCK_NAME)
)")
;

--create table REG_LOG
if not exists (select * from sysobjects where id = object_id('REG_LOG') and type in ('U'))
execute("create table REG_LOG (
	REG_LOG_ID integer identity NOT NULL,
	REG_PATH varchar (750), -- WAS: varchar (2000),
	REG_USER_ID varchar (31) NOT NULL,
	REG_LOGGED_TIME datetime NOT NULL,
	REG_ACTION integer NOT NULL,
	REG_ACTION_DATA varchar (500),
	REG_TENANT_ID integer default 0 NOT NULL,
	primary key (REG_LOG_ID, REG_TENANT_ID)
)")
;

if exists (select name from sysindexes where name = 'REG_LOG_IND_BY_REG_LOGTIME')
	drop index REG_LOG.REG_LOG_IND_BY_REG_LOGTIME
create index REG_LOG_IND_BY_REG_LOGTIME on REG_LOG(REG_LOGGED_TIME, REG_TENANT_ID)
;

--create table regpath
if not exists (select * from sysobjects where id = object_id('REG_PATH') and type in ('U'))
execute("create table  REG_PATH(
	REG_PATH_ID integer identity NOT NULL,
	REG_PATH_VALUE varchar(750) NOT NULL, -- WAS: varchar(2000)
	REG_PATH_PARENT_ID integer,
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint PK_REG_PATH primary key(REG_PATH_ID, REG_TENANT_ID)
)")
;

-- In ASE, we cannot use this index since it exceeds the 600 octets limit... It won't likely
-- matter, since the query would likely table scan on small tables (< 50000 rows).
--if exists (select name from sysindexes where name = 'REG_PATH_IND_BY_PATH_VALUE')
--	drop index REG_PATH.REG_PATH_IND_BY_PATH_VALUE
--create index REG_PATH_IND_BY_PATH_VALUE on REG_PATH(REG_PATH_VALUE, REG_TENANT_ID);

if exists (select name from sysindexes where name = 'REG_PATH_IND_BY_PARENT_ID')
	drop index REG_PATH.REG_PATH_IND_BY_PARENT_ID
create index REG_PATH_IND_BY_PARENT_ID on REG_PATH(REG_PATH_PARENT_ID, REG_TENANT_ID)
;
--create table regcontent

if not exists (select * from sysobjects where id = object_id('REG_CONTENT') and type in ('U'))
execute("create table  REG_CONTENT (
	REG_CONTENT_ID integer identity NOT NULL,
	REG_CONTENT_DATA image, -- WAS: varbinary(MAX),
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint PK_REG_CONTENT primary key(REG_CONTENT_ID, REG_TENANT_ID)
)")
;

--create table REG_CONTENT_HISTORY
if not exists (select * from sysobjects where id = object_id('REG_CONTENT_HISTORY') and type in ('U'))
execute("create table  REG_CONTENT_HISTORY (
	REG_CONTENT_ID integer NOT NULL,
	REG_CONTENT_DATA image, -- WAS: varbinary(MAX),
	REG_DELETED   smallint,
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint PK_REG_CONTENT_HISTORY primary key(REG_CONTENT_ID, REG_TENANT_ID)
)")
;


--create table REG_RESOURCE -- Exceeds 1962 octet row limit at 1970 octets
if not exists (select * from sysobjects where id = object_id('REG_RESOURCE') and type in ('U'))
execute("create table REG_RESOURCE (
	REG_PATH_ID         integer NOT NULL,
	REG_NAME            varchar(256),
	REG_VERSION          integer identity NOT NULL,
	REG_MEDIA_TYPE      varchar(500),
	REG_CREATOR         varchar(31) NOT NULL,
	REG_CREATED_TIME    datetime NOT NULL,
	REG_LAST_UPDATOR    varchar(31),
	REG_LAST_UPDATED_TIME   datetime NOT NULL,
	REG_DESCRIPTION     varchar(1000),
	REG_CONTENT_ID      integer,
	REG_TENANT_ID integer default 0 NOT NULL,
	REG_UUID varchar(100) NOT NULL,
	constraint PK_REG_RESOURCE primary key(REG_VERSION, REG_TENANT_ID),
	constraint REG_RESOURCE_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID)
)")
;

-- In ASE, add the constraint directly in the table create
--if not exists (SELECT * FROM SYS.FOREIGN_KEYS WHERE ID = OBJECT_ID(N'[DBO].[REG_RESOURCE_FK_BY_PATH_ID]') AND PARENT_ID = OBJECT_ID(N'[DBO].[REG_RESOURCE]'))
--ALTER TABLE REG_RESOURCE ADD CONSTRAINT REG_RESOURCE_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id('REG_RESOURCE_FK_BY_CONTENT_ID') AND PARENT_id = object_id('REG_RESOURCE'))
--alter table REG_RESOURCE add constraint REG_RESOURCE_FK_BY_CONTENT_ID foreign key (REG_CONTENT_ID, REG_TENANT_ID) references REG_CONTENT (REG_CONTENT_ID, REG_TENANT_ID);

if exists (select name from sysindexes where name = 'REG_RESOURCE_IND_BY_NAME')
	drop index REG_RESOURCE.REG_RESOURCE_IND_BY_NAME
create index REG_RESOURCE_IND_BY_NAME on REG_RESOURCE(REG_NAME, REG_TENANT_ID)
;

if exists (select name from sysindexes where name = 'REG_RESOURCE_IND_BY_PATH_ID_NAME')
	drop index REG_RESOURCE.REG_RESOURCE_IND_BY_PATH_ID_NAME
create index REG_RESOURCE_IND_BY_PATH_ID_NAME on REG_RESOURCE(REG_PATH_ID, REG_NAME, REG_TENANT_ID)
;

if exists (select name from sysindexes where name = 'REG_RESOURCE_IND_BY_UUID')
	drop index REG_RESOURCE.REG_RESOURCE_IND_BY_UUID
create index REG_RESOURCE_IND_BY_UUID on REG_RESOURCE(REG_UUID)
;

if exists (select name from sysindexes where name = 'REG_RESOURCE_IND_BY_TENANT')
	drop index REG_RESOURCE.REG_RESOURCE_IND_BY_TENANT
create index REG_RESOURCE_IND_BY_TENANT on REG_RESOURCE(REG_TENANT_ID, REG_UUID)
;

if exists (select name from sysindexes where name = 'REG_RESOURCE_IND_BY_TYPE')
	drop index REG_RESOURCE.REG_RESOURCE_IND_BY_TYPE
create index REG_RESOURCE_IND_BY_TYPE on REG_RESOURCE(REG_TENANT_ID, REG_MEDIA_TYPE)
;

--create table REG_RESOURCE_HISTORY - exceeds 1962 octet row limit at 1973 octets 
if not exists (select * from sysobjects where id = object_id('REG_RESOURCE_HISTORY') and type in ('U'))
execute("create table  REG_RESOURCE_HISTORY (
	REG_PATH_ID         integer NOT NULL,
	REG_NAME            varchar(256),
	REG_VERSION         integer NOT NULL,
	REG_MEDIA_TYPE      varchar(500),
	REG_CREATOR         varchar(31) NOT NULL,
	REG_CREATED_TIME    datetime NOT NULL,
	REG_LAST_UPDATOR    varchar(31),
	REG_LAST_UPDATED_TIME  datetime NOT NULL,
	REG_DESCRIPTION     varchar(1000),
	REG_CONTENT_ID      integer,
	REG_DELETED         smallint,
	REG_TENANT_ID integer default 0 NOT NULL,
	REG_UUID varchar(100) NOT NULL,
	constraint PK_REG_RESOURCE_HISTORY primary key(REG_VERSION, REG_TENANT_ID),
	constraint REG_RESOURCE_HIST_FK_BY_PATHID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID),
	constraint REG_RESOURCE_HIST_FK_BY_CONTENT_ID foreign key (REG_CONTENT_ID, REG_TENANT_ID) references REG_CONTENT_HISTORY (REG_CONTENT_ID, REG_TENANT_ID)
)")
;

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where object_id = object_id('REG_RESOURCE_HIST_FK_BY_PATHID') AND parent_object_id = object_id('REG_RESOURCE_HISTORY'))
--alter table REG_RESOURCE_HISTORY add constraint REG_RESOURCE_HIST_FK_BY_PATHID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID);

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where object_id = object_id('REG_RESOURCE_HIST_FK_BY_CONTENT_ID') AND parent_object_id = object_id('REG_RESOURCE_HISTORY'))
--alter table REG_RESOURCE_HISTORY add constraint REG_RESOURCE_HIST_FK_BY_CONTENT_ID foreign key (REG_CONTENT_ID, REG_TENANT_ID) references REG_CONTENT_HISTORY (REG_CONTENT_ID, REG_TENANT_ID);

if exists (select name from sysindexes where name = 'REG_RESOURCE_HISTORY_IND_BY_NAME')
	drop index REG_RESOURCE_HISTORY.REG_RESOURCE_HISTORY_IND_BY_NAME
create index REG_RESOURCE_HISTORY_IND_BY_NAME on REG_RESOURCE_HISTORY(REG_NAME, REG_TENANT_ID)
;

if exists (select name from sysindexes where name = 'REG_RESOURCE_HISTORY_IND_BY_PATH_ID_NAME')
	drop index REG_RESOURCE_HISTORY.REG_RESOURCE_HISTORY_IND_BY_PATH_ID_NAME
create index REG_RESOURCE_HISTORY_IND_BY_PATH_ID_NAME on REG_RESOURCE_HISTORY(REG_PATH_ID, REG_NAME, REG_TENANT_ID)
;

--create table REG_COMMENT

if not exists (select * from sysobjects where id = object_id('REG_COMMENT') and type in ('U'))
execute("create table  REG_COMMENT (
	REG_ID      integer identity NOT NULL,
	REG_COMMENT_TEXT      varchar(500) NOT NULL,
	REG_USER_ID           varchar(31) NOT NULL,
	REG_COMMENTED_TIME    datetime NOT NULL,
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint PK_REG_COMMENT primary key(REG_ID, REG_TENANT_ID)
)")
;

--create table REG_RESOURCE_COMMENT
if not exists (select * from sysobjects where id = object_id('REG_RESOURCE_COMMENT') and type in ('U'))
execute("create table  REG_RESOURCE_COMMENT (
	REG_COMMENT_ID          integer NOT NULL,
	REG_VERSION             integer default 0,
	REG_PATH_ID             integer,
	REG_RESOURCE_NAME       varchar(256),
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint REG_RESOURCE_COMMENT_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID),
	constraint REG_RESOURCE_COMMENT_FK_BY_COMMENT_ID foreign key (REG_COMMENT_ID, REG_TENANT_ID) references REG_COMMENT (REG_ID, REG_TENANT_ID)
)")
;

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id(N'[dbo].REG_RESOURCE_COMMENT_FK_BY_PATH_ID') AND PARENT_id = object_id(N'[DBO].REG_RESOURCE_COMMENT'))
--alter table REG_RESOURCE_COMMENT add constraint REG_RESOURCE_COMMENT_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID);

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id(N'[dbo].REG_RESOURCE_COMMENT_FK_BY_COMMENT_ID') AND PARENT_id = object_id(N'[DBO].REG_RESOURCE_COMMENT'))
--alter table REG_RESOURCE_COMMENT add constraint REG_RESOURCE_COMMENT_FK_BY_COMMENT_ID foreign key (REG_COMMENT_ID, REG_TENANT_ID) references REG_COMMENT (REG_ID, REG_TENANT_ID);

if exists (select name from sysindexes where name = 'REG_RESOURCE_COMMENT_IND_BY_PATH_ID_AND_RESOURCE_NAME')
	drop index REG_RESOURCE_COMMENT.REG_RESOURCE_COMMENT_IND_BY_PATH_ID_AND_RESOURCE_NAME
create index REG_RESOURCE_COMMENT_IND_BY_PATH_ID_AND_RESOURCE_NAME on REG_RESOURCE_COMMENT(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID)
;

if exists (select name from sysindexes where name = 'REG_RESOURCE_COMMENT_IND_BY_VERSION')
	drop index REG_RESOURCE_COMMENT.REG_RESOURCE_COMMENT_IND_BY_VERSION
create index REG_RESOURCE_COMMENT_IND_BY_VERSION on REG_RESOURCE_COMMENT(REG_VERSION, REG_TENANT_ID)
;

--create table  REG_RATING
if not exists (select * from sysobjects where id = object_id('REG_RATING') and type in ('U'))
execute("create table REG_RATING (
	REG_ID      integer identity NOT NULL,
	REG_RATING        integer NOT NULL,
	REG_USER_ID       varchar(31) NOT NULL,
	REG_RATED_TIME    datetime NOT NULL,
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint PK_REG_RATING primary key(REG_ID, REG_TENANT_ID)
)")
;

--create table REG_RESOURCE_RATING

if not exists (select * from sysobjects where id = object_id('REG_RESOURCE_RATING') and type in ('U'))
execute("create table  REG_RESOURCE_RATING (
	REG_RATING_ID           integer NOT NULL,
	REG_VERSION             integer,
	REG_PATH_ID             integer,
	REG_RESOURCE_NAME       varchar(256),
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint REG_RESOURCE_RATING_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID),
	constraint REG_RESOURCE_RATING_FK_BY_RATING_ID foreign key (REG_RATING_ID, REG_TENANT_ID) references REG_RATING (REG_ID, REG_TENANT_ID)
)")
;

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id(N'[dbo].REG_RESOURCE_RATING_FK_BY_PATH_ID') AND PARENT_id = object_id(N'[dbo].REG_RESOURCE_RATING'))
--alter table REG_RESOURCE_RATING add constraint REG_RESOURCE_RATING_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID);

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id(N'[dbo].REG_RESOURCE_RATING_FK_BY_RATING_ID') AND PARENT_id = object_id(N'[dbo].REG_RESOURCE_RATING'))
--alter table REG_RESOURCE_RATING add constraint REG_RESOURCE_RATING_FK_BY_RATING_ID foreign key (REG_RATING_ID, REG_TENANT_ID) references REG_RATING (REG_ID, REG_TENANT_ID);

if exists (select name from sysindexes where name = 'REG_RESOURCE_RATING_IND_BY_PATH_ID_AND_RESOURCE_NAME')
	drop index REG_RESOURCE_RATING.REG_RESOURCE_RATING_IND_BY_PATH_ID_AND_RESOURCE_NAME
create index REG_RESOURCE_RATING_IND_BY_PATH_ID_AND_RESOURCE_NAME on REG_RESOURCE_RATING(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID)
;

if exists (select name from sysindexes where name = 'REG_RESOURCE_RATING_IND_BY_VERSION')
	drop index REG_RESOURCE_RATING.REG_RESOURCE_RATING_IND_BY_VERSION
create index REG_RESOURCE_RATING_IND_BY_VERSION on REG_RESOURCE_RATING(REG_VERSION, REG_TENANT_ID)
;

--create table  REG_TAG

if not exists (select * from sysobjects where id = object_id('REG_TAG') and type in ('U'))
execute("create table  REG_TAG (
	REG_ID         integer identity NOT NULL,
	REG_TAG_NAME       varchar(500) NOT NULL,
	REG_USER_ID        varchar(31) NOT NULL,
	REG_TAGGED_TIME    datetime NOT NULL,
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint PK_REG_TAG primary key(REG_ID, REG_TENANT_ID)
)")
;



--create table  REG_RESOURCE_TAG

if not exists (select * from sysobjects where id = object_id('REG_RESOURCE_TAG') and type in ('U'))
execute("create table   REG_RESOURCE_TAG (
	REG_TAG_ID              integer NOT NULL,
	REG_VERSION             integer default 0,
	REG_PATH_ID             integer,
	REG_RESOURCE_NAME       varchar(256),
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint REG_RESOURCE_TAG_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID),
	constraint REG_RESOURCE_TAG_FK_BY_TAG_ID foreign key (REG_TAG_ID, REG_TENANT_ID) references REG_TAG (REG_ID, REG_TENANT_ID)
)")
;

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id(N'[DBO].REG_RESOURCE_TAG_FK_BY_PATH_ID') AND PARENT_id = object_id(N'[DBO].REG_RESOURCE_TAG'))
--alter table REG_RESOURCE_TAG add constraint REG_RESOURCE_TAG_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID);

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id(N'[DBO].REG_RESOURCE_TAG_FK_BY_TAG_ID') AND PARENT_id = object_id(N'[DBO].REG_RESOURCE_TAG'))
--alter table REG_RESOURCE_TAG add constraint REG_RESOURCE_TAG_FK_BY_TAG_ID foreign key (REG_TAG_ID, REG_TENANT_ID) references REG_TAG (REG_ID, REG_TENANT_ID);

if exists (select name from sysindexes where name = 'REG_RESOURCE_TAG_IND_BY_PATH_ID_AND_RESOURCE_NAME')
	drop index REG_RESOURCE_TAG.REG_RESOURCE_TAG_IND_BY_PATH_ID_AND_RESOURCE_NAME
create index REG_RESOURCE_TAG_IND_BY_PATH_ID_AND_RESOURCE_NAME on REG_RESOURCE_TAG(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID)
;

if exists (select name from sysindexes where name = 'REG_RESOURCE_TAG_IND_BY_VERSION')
	drop index REG_RESOURCE_TAG.REG_RESOURCE_TAG_IND_BY_VERSION
create index REG_RESOURCE_TAG_IND_BY_VERSION on REG_RESOURCE_TAG(REG_VERSION, REG_TENANT_ID)
;

--create table REG_PROPERTY

if not exists (select * from sysobjects where id = object_id('REG_PROPERTY') and type in ('U'))
execute("create table REG_PROPERTY (
	REG_ID        integer identity NOT NULL,
	REG_NAME       varchar(100) NOT NULL,
	REG_VALUE        varchar(1000),
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint PK_REG_PROPERTY primary key(REG_ID, REG_TENANT_ID)
)")
;

--create table REG_RESOURCE_PROPERTY

if not exists (select * from sysobjects where id = object_id('REG_RESOURCE_PROPERTY') and type in ('U'))
execute("create table  REG_RESOURCE_PROPERTY (
	REG_PROPERTY_ID         integer NOT NULL,
	REG_VERSION             integer,
	REG_PATH_ID             integer,
	REG_RESOURCE_NAME       varchar(256),
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint REG_RESOURCE_PROPERTY_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID),
	constraint REG_RESOURCE_PROPERTY_FK_BY_TAG_ID foreign key (REG_PROPERTY_ID, REG_TENANT_ID) references REG_PROPERTY (REG_ID, REG_TENANT_ID)
)")
;

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id(N'[DBO].REG_RESOURCE_PROPERTY_FK_BY_PATH_ID') AND PARENT_id = object_id(N'[DBO].REG_RESOURCE_PROPERTY'))
--alter table REG_RESOURCE_PROPERTY add constraint REG_RESOURCE_PROPERTY_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID);

-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id(N'[DBO].REG_RESOURCE_PROPERTY_FK_BY_TAG_ID') AND PARENT_id = object_id(N'[DBO].REG_RESOURCE_PROPERTY'))
--alter table REG_RESOURCE_PROPERTY add constraint REG_RESOURCE_PROPERTY_FK_BY_TAG_ID foreign key (REG_PROPERTY_ID, REG_TENANT_ID) references REG_PROPERTY (REG_ID, REG_TENANT_ID);

if exists (select name from sysindexes where name = 'REG_RESOURCE_PROPERTY_IND_BY_PATH_ID_AND_RESOURCE_NAME')
	drop index REG_RESOURCE_PROPERTY.REG_RESOURCE_PROPERTY_IND_BY_PATH_ID_AND_RESOURCE_NAME
create index REG_RESOURCE_PROPERTY_IND_BY_PATH_ID_AND_RESOURCE_NAME on REG_RESOURCE_PROPERTY(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID)
;

if exists (select name from sysindexes where name = 'REG_RESOURCE_PROPERTY_IND_BY_VERSION')
	drop index REG_RESOURCE_PROPERTY.REG_RESOURCE_PROPERTY_IND_BY_VERSION
create index REG_RESOURCE_PROPERTY_IND_BY_VERSION on REG_RESOURCE_PROPERTY(REG_VERSION, REG_TENANT_ID)
;

--create table  REG_ASSOCIATION

if not exists (select * from sysobjects where id = object_id('REG_ASSOCIATION') and type in ('U'))
execute("create table  REG_ASSOCIATION (
	REG_ASSOCIATION_ID  integer identity NOT NULL,
	REG_SOURCEPATH varchar (750) NOT NULL, -- WAS: varchar(2000)
	REG_TARGETPATH varchar (750) NOT NULL, -- WAS: varchar(2000)
	REG_ASSOCIATION_TYPE text NOT NULL, -- WAS: varchar(2000)
	REG_TENANT_ID integer default 0 NOT NULL,
	primary key (REG_ASSOCIATION_ID, REG_TENANT_ID)
)")
;

--create table  REG_SNAPSHOT
if not exists (select * from sysobjects where id = object_id('REG_SNAPSHOT') and type in ('U'))
execute("create table REG_SNAPSHOT (
	REG_SNAPSHOT_ID     integer identity NOT NULL,
	REG_PATH_ID            integer NOT NULL,
	REG_RESOURCE_NAME            varchar (256),
	REG_RESOURCE_VIDS     image NOT NULL, -- WAS: varbinary(MAX)
	REG_TENANT_ID integer default 0 NOT NULL,
	constraint PK_REG_SNAPSHOT primary key(REG_SNAPSHOT_ID, REG_TENANT_ID),
	constraint REG_SNAPSHOT_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID)
)")
;
-- In ASE, add the constraint directly in the table create
--if not exists (select * from SYS.FOREIGN_KEYS where id = object_id(N'[DBO].REG_SNAPSHOT_FK_BY_PATH_ID') AND PARENT_id = object_id(N'[DBO].REG_SNAPSHOT'))
--alter table REG_SNAPSHOT add constraint REG_SNAPSHOT_FK_BY_PATH_ID foreign key (REG_PATH_ID, REG_TENANT_ID) references REG_PATH (REG_PATH_ID, REG_TENANT_ID);

if exists (select name from sysindexes where name = 'REG_SNAPSHOT_IND_BY_PATH_ID_AND_RESOURCE_NAME')
	drop index REG_SNAPSHOT.REG_SNAPSHOT_IND_BY_PATH_ID_AND_RESOURCE_NAME
create index REG_SNAPSHOT_IND_BY_PATH_ID_AND_RESOURCE_NAME on REG_SNAPSHOT(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID)
;

-- ################################
-- USER MANAGER TABLES
-- ################################

--create table   UM_TENANT_

if not exists (select * from sysobjects where id = object_id('UM_TENANT') and type in ('U'))
execute("create table UM_TENANT (
	UM_ID integer identity NOT NULL,
	UM_DOMAIN_NAME varchar(255) NOT NULL,
	UM_EMAIL varchar(255),
	UM_ACTIVE bit default 0 NOT NULL,
	UM_CREATED_DATE datetime NOT NULL,
	UM_USER_CONFIG image, -- WAS: varbinary(MAX),
	primary key (UM_ID),
	unique (UM_DOMAIN_NAME)
)")
;

if exists (select name from sysindexes where name = 'INDEX_UM_TENANT_UM_DOMAIN_NAME')
	drop index UM_TENANT.INDEX_UM_TENANT_UM_DOMAIN_NAME
create index INDEX_UM_TENANT_UM_DOMAIN_NAME on UM_TENANT (UM_DOMAIN_NAME)
; 

--create table   UM_USER

if not exists (select * from sysobjects where id = object_id('UM_USER') and type in ('U'))
execute("create table  UM_USER (
	UM_ID integer identity NOT NULL,
	UM_USER_NAME varchar(255) NOT NULL,
	UM_USER_PASSWORD varchar(255) NOT NULL,
	UM_SALT_VALUE varchar(31),
	UM_REQUIRE_CHANGE bit default 0 NOT NULL,
	UM_CHANGED_TIME datetime NOT NULL,
	UM_TENANT_ID integer default 0 NOT NULL,
	primary key (UM_ID, UM_TENANT_ID),
	unique (UM_USER_NAME, UM_TENANT_ID)
)")
;

--create table   UM_DOMAIN
if not exists (select * from sysobjects where id = object_id('UM_DOMAIN') and type in ('U'))
execute("create table UM_DOMAIN(
	UM_DOMAIN_ID integer identity NOT NULL,
	UM_DOMAIN_NAME varchar(255),
	UM_TENANT_ID integer default 0 NOT NULL,
	primary key (UM_DOMAIN_ID, UM_TENANT_ID)
)")
;

--create table   UM_SYSTEM_USER
if not exists (select * from sysobjects where id = object_id('UM_SYSTEM_USER') and type in ('U'))
execute("create table UM_SYSTEM_USER ( 
	UM_ID integer identity NOT NULL, 
	UM_USER_NAME varchar(255) NOT NULL, 
	UM_USER_PASSWORD varchar(255) NOT NULL,
	UM_SALT_VALUE varchar(31),
	UM_REQUIRE_CHANGE  bit default 0 NOT NULL,
	UM_CHANGED_TIME datetime NOT NULL,
	UM_TENANT_ID integer default 0 NOT NULL, 
	primary key (UM_ID, UM_TENANT_ID), 
	unique (UM_USER_NAME, UM_TENANT_ID)
)")
; 


--create table   UM_USER_ATTRIBUTE

if not exists (select * from sysobjects where id = object_id('UM_USER_ATTRIBUTE') and type in ('U'))
execute("create table  UM_USER_ATTRIBUTE (
	UM_ID integer identity NOT NULL,
	UM_ATTR_NAME varchar(255) NOT NULL,
	UM_ATTR_VALUE varchar(1024),
	UM_PROFILE_ID varchar(255),
	UM_USER_ID integer,
	UM_TENANT_ID integer default 0 NOT NULL,
	foreign key (UM_USER_ID, UM_TENANT_ID) references UM_USER(UM_ID, UM_TENANT_ID),
	primary key (UM_ID, UM_TENANT_ID)
)")
;

if exists (select name from sysindexes where name = 'UM_USER_ID_INDEX')
	drop index UM_USER_ATTRIBUTE.UM_USER_ID_INDEX
create index UM_USER_ID_INDEX on UM_USER_ATTRIBUTE(UM_USER_ID)
;


--create table   UM_ROLE

if not exists (select * from sysobjects where id = object_id('UM_ROLE') and type in ('U'))
execute("create table UM_ROLE (
	UM_ID integer identity NOT NULL,
	UM_ROLE_NAME varchar(255) NOT NULL,
	UM_TENANT_ID integer default 0 NOT NULL,
	UM_SHARED_ROLE bit default 0 NOT NULL,
	primary key (UM_ID, UM_TENANT_ID),
	unique (UM_ROLE_NAME, UM_TENANT_ID)
)")
;
--CREATES TABLE UM_MODULE
if not exists (select * from sysobjects where id = object_id('UM_MODULE') and type in ('U'))
execute("create table UM_MODULE(
	UM_ID integer  identity NOT NULL,
	UM_MODULE_NAME varchar(100),
	unique (UM_MODULE_NAME),
	primary key(UM_ID)
)")
;

if not exists (select * from sysobjects where id = object_id('UM_MODULE_ACTIONS') and type in ('U'))
execute("create table UM_MODULE_ACTIONS(
	UM_ACTION varchar(255) NOT NULL,
	UM_MODULE_ID integer NOT NULL,
	primary key(UM_ACTION, UM_MODULE_ID)--,
	--foreign key (UM_MODULE_ID) references UM_MODULE(UM_ID) on delete  -- In ASE, implemented as triggers
)")
;
--create table UM_PERMISSION

if not exists (select * from sysobjects where id = object_id('UM_PERMISSION') and type in ('U'))
execute("create table  UM_PERMISSION (
	UM_ID integer identity NOT NULL,
	UM_RESOURCE_ID varchar(255) NOT NULL,
	UM_ACTION varchar(255) NOT NULL,
	UM_TENANT_ID integer default 0 NOT NULL,
	UM_MODULE_ID integer default 0,
	unique (UM_RESOURCE_ID,UM_ACTION, UM_TENANT_ID),
	primary key (UM_ID, UM_TENANT_ID)
)")
;
if exists (select name from sysindexes where name = 'INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION')
	drop index UM_PERMISSION.INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION
create index INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION on UM_PERMISSION (UM_RESOURCE_ID, UM_ACTION, UM_TENANT_ID)
;

--create table UM_ROLE_PERMISSION

if not exists (select * from sysobjects where id = object_id('UM_ROLE_PERMISSION') and type in ('U'))
execute("create table  UM_ROLE_PERMISSION (
	UM_ID integer identity NOT NULL,
	UM_PERMISSION_ID integer NOT NULL,
	UM_ROLE_NAME varchar(255) NOT NULL,
	UM_IS_ALLOWED smallint NOT NULL,
	UM_TENANT_ID integer default 0 NOT NULL,
	UM_DOMAIN_ID integer, 
	unique (UM_PERMISSION_ID, UM_ROLE_NAME, UM_TENANT_ID, UM_DOMAIN_ID),
	--foreign key (UM_PERMISSION_ID, UM_TENANT_ID) references UM_PERMISSION(UM_ID, UM_TENANT_ID) on delete cascade,-- In ASE, implemented as triggers
	--foreign key (UM_DOMAIN_ID, UM_TENANT_ID) references UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) on delete cascade, -- In ASE, implemented as triggers
	primary key (UM_ID, UM_TENANT_ID)
)")
;

--create table UM_USER_PERMISSION
if not exists (select * from sysobjects where id = object_id('UM_USER_PERMISSION') and type in ('U'))
execute("create table  UM_USER_PERMISSION (
	UM_ID integer identity NOT NULL,
	UM_PERMISSION_ID integer NOT NULL,
	UM_USER_NAME varchar(255) NOT NULL,
	UM_IS_ALLOWED smallint NOT NULL,
	UM_TENANT_ID integer default 0 NOT NULL,
	unique (UM_PERMISSION_ID, UM_USER_NAME, UM_TENANT_ID),
	--foreign key (UM_PERMISSION_ID, UM_TENANT_ID) references UM_PERMISSION(UM_ID, UM_TENANT_ID) on delete cascade, -- In ASE, implemented as triggers
	primary key (UM_ID, UM_TENANT_ID)
)")
;

-- create table UM_USER_ROLE
if not exists (select * from sysobjects where id = object_id('UM_USER_ROLE') and type in ('U'))
execute("create table  UM_USER_ROLE (
	UM_ID integer identity NOT NULL,
	UM_ROLE_ID integer NOT NULL,
	UM_USER_ID integer NOT NULL,
	UM_TENANT_ID integer default 0 NOT NULL,
	unique (UM_USER_ID, UM_ROLE_ID, UM_TENANT_ID),
	foreign key (UM_ROLE_ID, UM_TENANT_ID) references UM_ROLE(UM_ID, UM_TENANT_ID),
	foreign key (UM_USER_ID, UM_TENANT_ID) references UM_USER(UM_ID, UM_TENANT_ID),
	primary key (UM_ID, UM_TENANT_ID)
)")
;

if not exists (select * from sysobjects where id = object_id('UM_SHARED_USER_ROLE') and type in ('U'))
execute("create table UM_SHARED_USER_ROLE(
	UM_ROLE_ID integer NOT NULL,
	UM_USER_ID integer NOT NULL,
	UM_USER_TENANT_ID integer NOT NULL,
	UM_ROLE_TENANT_ID integer NOT NULL,
	unique (UM_USER_ID,UM_ROLE_ID,UM_USER_TENANT_ID, UM_ROLE_TENANT_ID)--,
	--foreign key(UM_ROLE_ID,UM_ROLE_TENANT_ID) references UM_ROLE(UM_ID,UM_TENANT_ID) on delete cascade,-- In ASE, implemented as triggers
	--foreign key(UM_USER_ID,UM_USER_TENANT_ID) references UM_USER(UM_ID,UM_TENANT_ID) on delete cascade -- In ASE, implemented as triggers
)")
;

if not exists (select * from sysobjects where id = object_id('UM_ACCOUNT_MAPPING') and type in ('U'))
execute("create table UM_ACCOUNT_MAPPING(
	UM_ID integer identity,
	UM_USER_NAME varchar(255) NOT NULL,
	UM_TENANT_ID integer NOT NULL,
	UM_USER_STORE_DOMAIN varchar(100),
	UM_ACC_LINK_ID integer NOT NULL,
	unique (UM_USER_NAME, UM_TENANT_ID, UM_USER_STORE_DOMAIN, UM_ACC_LINK_ID),
	-- foreign key (UM_TENANT_ID) references UM_TENANT(UM_ID) on delete cascade, -- In ASE, implemented as triggers
	primary key (UM_ID)
)")
;

-- create table UM_DIALECT
if not exists (select * from sysobjects where id = object_id('UM_DIALECT') and type in ('U'))
execute("create table UM_DIALECT(
	UM_ID integer identity,
	UM_DIALECT_URI varchar(255),
	UM_TENANT_ID integer default 0 NOT NULL,
	unique (UM_DIALECT_URI, UM_TENANT_ID),
	primary key (UM_ID, UM_TENANT_ID)
)")
;

-- create table UM_CLAIM
if not exists (select * from sysobjects where id = object_id('UM_CLAIM') and type in ('U'))
execute("create table UM_CLAIM(
	UM_ID integer identity,
	UM_DIALECT_ID integer,
	UM_CLAIM_URI varchar(255), 
	UM_DISPLAY_TAG varchar(255), 
	UM_DESCRIPTION varchar(255), 
	UM_MAPPED_ATTRIBUTE_DOMAIN varchar(255),
	UM_MAPPED_ATTRIBUTE varchar(255), 
	UM_REG_EX varchar(255), 
	UM_SUPPORTED smallint, 
	UM_REQUIRED smallint, 
	UM_DISPLAY_ORDER integer, 
	UM_CHECKED_ATTRIBUTE smallint,
	UM_READ_ONLY smallint,
	UM_TENANT_ID integer default 0 NOT NULL,
	unique (UM_DIALECT_ID, UM_CLAIM_URI, UM_TENANT_ID,UM_MAPPED_ATTRIBUTE_DOMAIN), 
	foreign key(UM_DIALECT_ID, UM_TENANT_ID) references UM_DIALECT(UM_ID, UM_TENANT_ID), 
	primary key (UM_ID, UM_TENANT_ID)
)")
;

-- create table UM_PROFILE_CONFIG
if not exists (select * from sysobjects where id = object_id('UM_PROFILE_CONFIG') and type in ('U'))
execute("create table UM_PROFILE_CONFIG(
	UM_ID integer identity,
	UM_DIALECT_ID integer, 
	UM_PROFILE_NAME varchar(255), 
	UM_TENANT_ID integer default 0 NOT NULL,
	foreign key(UM_DIALECT_ID, UM_TENANT_ID) references UM_DIALECT(UM_ID, UM_TENANT_ID), 
	primary key (UM_ID, UM_TENANT_ID)
)")
;

-- create table UM_CLAIM_BEHAVIOR
if not exists (select * from sysobjects where id = object_id('UM_CLAIM_BEHAVIOR') and type in ('U'))
execute("create table UM_CLAIM_BEHAVIOR(
	UM_ID integer identity,
	UM_PROFILE_ID integer, 
	UM_CLAIM_ID integer, 
	UM_BEHAVIOUR smallint,
	UM_TENANT_ID integer default 0 NOT NULL, 
	foreign key(UM_PROFILE_ID, UM_TENANT_ID) references UM_PROFILE_CONFIG(UM_ID, UM_TENANT_ID), 
	foreign key(UM_CLAIM_ID, UM_TENANT_ID) references UM_CLAIM(UM_ID, UM_TENANT_ID), 
	primary key (UM_ID, UM_TENANT_ID)
)")
;

-- create table UM_HYBRID_ROLE
if not exists (select * from sysobjects where id = object_id('UM_HYBRID_ROLE') and type in ('U'))
execute("create table UM_HYBRID_ROLE(
	UM_ID integer identity,
	UM_ROLE_NAME varchar(255),
	UM_TENANT_ID integer default 0 NOT NULL,
	primary key (UM_ID, UM_TENANT_ID)
)")
;
-- create table UM_HYBRID_USER_ROLE
if not exists (select * from sysobjects where id = object_id('UM_HYBRID_USER_ROLE') and type in ('U'))
execute("create table UM_HYBRID_USER_ROLE(
	UM_ID integer identity NOT NULL,
	UM_USER_NAME varchar(255),
	UM_ROLE_ID integer NOT NULL,
	UM_TENANT_ID integer default 0 NOT NULL,
	UM_DOMAIN_ID integer,
	unique (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID, UM_DOMAIN_ID),
	--foreign key (UM_ROLE_ID, UM_TENANT_ID) references UM_HYBRID_ROLE(UM_ID, UM_TENANT_ID) on delete cascade, -- In ASE, implemented as triggers
	--foreign key (UM_DOMAIN_ID, UM_TENANT_ID) references UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) on delete cascade, -- In ASE, implemented as triggers
	primary key (UM_ID, UM_TENANT_ID)
)")
;
-- create table UM_SYSTEM_ROLE
if not exists (select * from sysobjects where id = object_id('UM_SYSTEM_ROLE') and type in ('U'))
execute("create table UM_SYSTEM_ROLE(
	UM_ID integer identity NOT NULL,
	UM_ROLE_NAME varchar(255),
	UM_TENANT_ID integer default 0 NOT NULL,
	primary key (UM_ID, UM_TENANT_ID)
)")
;

if exists (select name from sysindexes where name = 'SYSTEM_ROLE_IND_BY_RN_TI')
	drop index UM_SYSTEM_ROLE.SYSTEM_ROLE_IND_BY_RN_TI
create index SYSTEM_ROLE_IND_BY_RN_TI on UM_SYSTEM_ROLE(UM_ROLE_NAME, UM_TENANT_ID)
;

-- create table UM_SYSTEM_USER_ROLE
if not exists (select * from sysobjects where id = object_id('UM_SYSTEM_USER_ROLE') and type in ('U'))
execute("create table UM_SYSTEM_USER_ROLE(
	UM_ID integer identity,
	UM_USER_NAME varchar(255),
	UM_ROLE_ID integer NOT NULL,
	UM_TENANT_ID integer default 0 NOT NULL,
	unique (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID),
	foreign key (UM_ROLE_ID, UM_TENANT_ID) references UM_SYSTEM_ROLE(UM_ID, UM_TENANT_ID),
	primary key (UM_ID, UM_TENANT_ID)
)")
;

-- create table UM_HYBRID_USER_ROLE
if not exists (select * from sysobjects where id = object_id('UM_HYBRID_REMEMBER_ME') and type in ('U'))
execute("create table UM_HYBRID_REMEMBER_ME(
	UM_ID integer identity,
	UM_USER_NAME varchar(255) NOT NULL,
	UM_COOKIE_VALUE varchar(1024),
	UM_CREATED_TIME datetime,
	UM_TENANT_ID integer default 0 NOT NULL,
	primary key (UM_ID, UM_TENANT_ID)
)")
;

--------------------------------------------------------------------------------
-- ASE doesn't support on delete cascade foreign key table constraints, 
-- so we have to implement these using triggers instead.
--------------------------------------------------------------------------------
-- ASE Cascade deletion RI triggers
--------------------------------------------------------------------------------

-- create trigger UM_TENANT_TRIGGER to handle RI cascade deletion of UM_ACCOUNT_MAPPING
if exists ( select * from sysobjects where id = object_id('UM_TENANT_TRIGGER') and type = 'TR' )
	drop trigger UM_TENANT_TRIGGER
;
create trigger UM_TENANT_TRIGGER on UM_TENANT
for delete as
	delete UM_ACCOUNT_MAPPING
	  from deleted d, UM_ACCOUNT_MAPPING r 
	 where d.UM_ID = r.UM_TENANT_ID
;

-- create trigger UM_USER_TRIGGER to handle RI cascade deletion of UN_SHARED_USER_ROLE
if exists ( select * from sysobjects where id = object_id('UM_USER_TRIGGER') and type = 'TR' )
	drop trigger UM_USER_TRIGGER
;
create trigger UM_USER_TRIGGER on UM_USER
for delete as
	delete UM_SHARED_USER_ROLE
	  from deleted d, UM_SHARED_USER_ROLE r 
	 where d.UM_ID = r.UM_USER_ID 
	   and d.UM_TENANT_ID = r.UM_USER_TENANT_ID
;

--create trigger UM_DOMAIN_TRIGGER to handle RI cascade deletion of UM_ROLE_PERMISSION and UM_DOMAIN RI
if exists ( select * from sysobjects where id = object_id('UM_DOMAIN_TRIGGER') and type = 'TR' )
	drop trigger UM_DOMAIN_TRIGGER
;
create trigger UM_DOMAIN_TRIGGER on UM_DOMAIN
for delete as
	delete UM_ROLE_PERMISSION
	  from deleted d, UM_ROLE_PERMISSION r 
	 where d.UM_DOMAIN_ID = r.UM_DOMAIN_ID
	   and d.UM_TENANT_ID = r.UM_TENANT_ID
	delete UM_DOMAIN
	  from deleted d, UM_ROLE_PERMISSION r 
	 where d.UM_DOMAIN_ID = r.UM_DOMAIN_ID
	   and d.UM_TENANT_ID = r.UM_TENANT_ID
;

--create trigger UM_ROLE_TRIGGER to handle RI cascade deletion of UM_SHARED_USER_ROLE
if exists ( select * from sysobjects where id = object_id('UM_ROLE_TRIGGER') and type = 'TR' )
	drop trigger UM_ROLE_TRIGGER
;
create trigger UM_ROLE_TRIGGER on UM_ROLE
for delete as
	delete UM_SHARED_USER_ROLE 
	  from deleted d, UM_SHARED_USER_ROLE r 
	 where d.UM_ID = r.UM_ROLE_ID
	   and d.UM_TENANT_ID = r.UM_ROLE_TENANT_ID
;

--create trigger UM_PERMISSION_TRIGGER to handle RI cascade deletion of UM_ROLE_PERMISSION and UM_USER_PERMISSION
if exists ( select * from sysobjects where id = object_id('UM_PERMISSION_TRIGGER') and type = 'TR' )
	drop trigger UM_PERMISSION_TRIGGER
;
create trigger UM_PERMISSION_TRIGGER on UM_PERMISSION
for delete as
	delete UM_ROLE_PERMISSION 
	  from deleted d, UM_ROLE_PERMISSION r
	 where d.UM_ID = r.UM_PERMISSION_ID
	   and d.UM_TENANT_ID = r.UM_TENANT_ID
	delete UM_USER_PERMISSION
	  from deleted d, UM_USER_PERMISSION r
	 where d.UM_ID = r.UM_PERMISSION_ID
	   and d.UM_TENANT_ID = r.UM_TENANT_ID
;

if exists ( select * from sysobjects where id = object_id('UM_HYBRID_ROLE_TRIGGER') and type = 'TR' )
	drop trigger UM_HYBRID_ROLE_TRIGGER
;
create trigger UM_HYBRID_ROLE_TRIGGER on UM_HYBRID_ROLE
for delete as
	delete UM_HYBRID_USER_ROLE 
	  from deleted d, UM_HYBRID_USER_ROLE r
	 where d.UM_ID = r.UM_ROLE_ID
	   and d.UM_TENANT_ID = r.UM_TENANT_ID
;

-----------------------------------------
-- ASE foreign key RI constraint triggers
-----------------------------------------

-- create trigger UM_MODULE_ACTIONS_TRIGGER to handle RI foreign key constraints on UM_MODULE for delete cascade support
if exists ( select * from sysobjects where id = object_id('UM_MODULE_ACTIONS_TRIGGER') and type = 'TR' )
	drop trigger UM_MODULE_ACTIONS_TRIGGER
;
create trigger UM_MODULE_ACTIONS_TRIGGER on UM_MODULE_ACTIONS
   for insert, update as
declare @rowcount integer, @db_name varchar(255), @table_name varchar(255), @foreign_table_name varchar(255)
set @rowcount = @@rowcount
set @db_name = db_name()
set @table_name = 'UM_MODULE_ACTIONS'
set @foreign_table_name = 'UM_MODULE'
if ( select count(*) from UM_MODULE r, inserted i 
     where r.UM_ID = i.UM_MODULE_ID ) != @rowcount
	rollback trigger with raiserror 99999
		"Foreign key constraint violation occurred, dbname = '%1!', table name = '%2!', foreign table name = '%3!'", @db_name, @table_name, @foreign_table_name
;

-- create trigger UM_ROLE_PERMISSION_TRIGGER to handle RI foreign key constraints on UM_PERMISSION and UM_DOMAIN for delete cascade support
if exists ( select * from sysobjects where id = object_id('UM_ROLE_PERMISSION_TRIGGER') and type = 'TR' )
	drop trigger UM_ROLE_PERMISSION_TRIGGER
;
create trigger UM_ROLE_PERMISSION_TRIGGER on UM_ROLE_PERMISSION
   for insert, update as
declare @rowcount integer, @db_name varchar(255), @table_name varchar(255), @foreign_table_name varchar(255)
set @rowcount = @@rowcount
set @db_name = db_name()
set @table_name = 'UM_ROLE_PERMISSION'
set @foreign_table_name = 'UM_PERMISSION'
if ( select count(*) from UM_PERMISSION r, inserted i 
     where r.UM_ID = i.UM_PERMISSION_ID 
       and r.UM_TENANT_ID = i.UM_TENANT_ID ) != @rowcount
	rollback trigger with raiserror 99999
		"Foreign key constraint violation occurred, dbname = '%1!', table name = '%2!', foreign table name = '%3!'", @db_name, @table_name, @foreign_table_name
set @foreign_table_name = 'UM_DOMAIM'
if ( select count(*) from UM_DOMAIN r, inserted i 
     where r.UM_DOMAIN_ID = i.UM_DOMAIN_ID
       and r.UM_TENANT_ID = i.UM_TENANT_ID ) != @rowcount
	rollback trigger with raiserror 99999
		"Foreign key constraint violation occurred, dbname = '%1!', table name = '%2!', foreign table name = '%3!'", @db_name, @table_name, @foreign_table_name
;

-- create trigger UM_USER_PERMISSION_TRIGGER to handle RI foreign key constraints on UM_PERMISSION for delete cascade support
if exists ( select * from sysobjects where id = object_id('UM_USER_PERMISSION_TRIGGER') and type = 'TR' )
	drop trigger UM_USER_PERMISSION_TRIGGER
;
create trigger UM_USER_PERMISSION_TRIGGER on UM_USER_PERMISSION
   for insert, update as
declare @rowcount integer, @db_name varchar(255), @table_name varchar(255), @foreign_table_name varchar(255)
set @rowcount = @@rowcount
set @db_name = db_name()
set @table_name = 'UM_USER_PERMISSION'
set @foreign_table_name = 'UM_PERMISSION'
if ( select count(*) from UM_PERMISSION r, inserted i 
      where r.UM_ID = i.UM_PERMISSION_ID 
        and r.UM_TENANT_ID = i.UM_TENANT_ID ) != @rowcount
	rollback trigger with raiserror 99999
		"Foreign key constraint violation occurred, dbname = '%1!', table name = '%2!', foreign table name = '%3!'", @db_name, @table_name, @foreign_table_name
;

-- create trigger UM_SHARED_USER_ROLE_TRIGGER to handle RI foreign key constraints on UM_ROLE and UM_USER for delete cascade support
if exists ( select * from sysobjects where id = object_id('UM_SHARED_USER_ROLE_TRIGGER') and type = 'TR' )
	drop trigger UM_SHARED_USER_ROLE_TRIGGER
;
create trigger UM_SHARED_USER_ROLE_TRIGGER on UM_SHARED_USER_ROLE
   for insert, update as
declare @rowcount integer, @db_name varchar(255), @table_name varchar(255), @foreign_table_name varchar(255)
set @rowcount = @@rowcount
set @db_name = db_name()
set @table_name = 'UM_SHARED_USER_ROLE'
set @foreign_table_name = 'UM_ROLE'
if ( select count(*) from UM_ROLE r, inserted i 
      where r.UM_ID = i.UM_ROLE_ID 
        and r.UM_TENANT_ID = i.UM_ROLE_TENANT_ID ) != @rowcount
	rollback trigger with raiserror 99999
		"Foreign key constraint violation occurred, dbname = '%1!', table name = '%2!', foreign table name = '%3!'", @db_name, @table_name, @foreign_table_name
set @foreign_table_name = 'UM_USER'
if ( select count(*) from UM_USER r, inserted i 
      where r.UM_ID = i.UM_USER_ID 
        and r.UM_TENANT_ID = i.UM_USER_TENANT_ID ) != @rowcount
	rollback trigger with raiserror 99999
		"Foreign key constraint violation occurred, dbname = '%1!', table name = '%2!', foreign table name = '%3!'", @db_name, @table_name, @foreign_table_name
;

if exists ( select * from sysobjects where id = object_id('UM_ACCOUNT_MAPPING_TRIGGER') and type = 'TR' )
	drop trigger UM_ACCOUNT_MAPPING_TRIGGER
;
create trigger UM_ACCOUNT_MAPPING_TRIGGER on UM_ACCOUNT_MAPPING
   for insert, update as
declare @rowcount integer, @db_name varchar(255), @table_name varchar(255), @foreign_table_name varchar(255)
set @rowcount = @@rowcount
set @db_name = db_name()
set @table_name = 'UM_ACCOUNT_MAPPING'
set @foreign_table_name = 'UM_TENANT'
if ( select count(*) from UM_TENANT r, inserted i 
      where r.UM_ID = i.UM_TENANT_ID ) != @rowcount
	rollback trigger with raiserror 99999
		"Foreign key constraint violation occurred, dbname = '%1!', table name = '%2!', foreign table name = '%3!'", @db_name, @table_name, @foreign_table_name
;

if exists ( select * from sysobjects where id = object_id('UM_HYBRID_USER_ROLE_TRIGGER') and type = 'TR' )
	drop trigger UM_HYBRID_USER_ROLE_TRIGGER
;
create trigger UM_HYBRID_USER_ROLE_TRIGGER on UM_HYBRID_USER_ROLE
   for insert, update as
declare @rowcount integer, @db_name varchar(255), @table_name varchar(255), @foreign_table_name varchar(255)
set @rowcount = @@rowcount
set @db_name = db_name()
set @table_name = 'UM_HYBRID_USER_ROLE'
set @foreign_table_name = 'UM_HYBRID_ROLE'
if ( select count(*) from UM_HYBRID_ROLE r, inserted i 
     where r.UM_ID = i.UM_ROLE_ID 
       and r.UM_TENANT_ID = i.UM_TENANT_ID ) != @rowcount
	rollback trigger with raiserror 99999
		"Foreign key constraint violation occurred, dbname = '%1!', table name = '%2!', foreign table name = '%3!'", @db_name, @table_name, @foreign_table_name
set @foreign_table_name = 'UM_DOMAIN'
if ( select count(*) from UM_DOMAIN r, inserted i 
      where r.UM_DOMAIN_ID = i.UM_DOMAIN_ID
        and r.UM_TENANT_ID = i.UM_TENANT_ID ) != @rowcount
	rollback trigger with raiserror 99999
		"Foreign key constraint violation occurred, dbname = '%1!', table name = '%2!', foreign table name = '%3!'", @db_name, @table_name, @foreign_table_name
;
