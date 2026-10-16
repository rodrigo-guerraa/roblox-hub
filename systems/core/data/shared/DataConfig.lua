local DataConfig = {}

DataConfig.STORE_NAME = "PlayerData"
DataConfig.KEY_PREFIX = "Player_"
DataConfig.STUDIO_SUFFIX = "_Studio"

-- bump with a DataMigrations step for the old version; never rename STORE_NAME to change the format
DataConfig.DATA_VERSION = 1
DataConfig.MIGRATION_BASELINE = 1

DataConfig.PURCHASE_HISTORY = 50

return DataConfig
