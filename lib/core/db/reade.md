take a look to "db_floor_migration.dart" file

I changed a little bit code inside "onUpgrade" method

    onUpgrade: (database, startVersion, endVersion) async {
        if (migrations.isNotEmpty) {
          await MigrationAdapter.runMigrations(database, startVersion, endVersion, migrations);

          await callback?.onUpgrade?.call(database, startVersion, endVersion);
        }
    },


https://pinchbv.github.io/floor/