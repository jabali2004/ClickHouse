---
slug: /ru/engines/database-engines/atomic
sidebar_position: 32
sidebar_label: Atomic
---

# Atomic {#atomic}

Поддерживает неблокирующие запросы [DROP TABLE](#drop-detach-table) и [RENAME TABLE](#rename-table) и атомарные запросы [EXCHANGE TABLES](#exchange-tables). Движок `Atomic` используется по умолчанию.

## Создание БД {#creating-a-database}

``` sql
CREATE DATABASE test [ENGINE = Atomic];
```

## Особенности и рекомендации {#specifics-and-recommendations}

### UUID {#table-uuid}

Каждая таблица в базе данных `Atomic` имеет уникальный [UUID](../../sql-reference/data-types/uuid.md) и хранит данные в папке `/clickhouse_path/store/xxx/xxxyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy/`, где `xxxyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy` - это UUID таблицы.
Обычно UUID генерируется автоматически, но пользователь также может явно указать UUID в момент создания таблицы (однако это не рекомендуется). Для отображения UUID в запросе `SHOW CREATE` вы можете использовать настройку [show_table_uuid_in_table_create_query_if_not_nil](../../operations/settings/settings.md#show_table_uuid_in_table_create_query_if_not_nil). Результат выполнения в таком случае будет иметь вид:

```sql
CREATE TABLE name UUID '28f1c61c-2970-457a-bffe-454156ddcfef' (n UInt64) ENGINE = ...;
```
### RENAME TABLE {#rename-table}

Запросы [RENAME](../../sql-reference/statements/rename.md) выполняются без изменения UUID и перемещения табличных данных. Эти запросы не ожидают завершения использующих таблицу запросов и выполняются мгновенно.

### DROP/DETACH TABLE {#drop-detach-table}

При выполнении запроса `DROP TABLE` никакие данные не удаляются. Таблица помечается как удаленная, метаданные перемещаются в папку `/clickhouse_path/metadata_dropped/` и база данных уведомляет фоновый поток. Задержка перед окончательным удалением данных задается настройкой [database_atomic_delay_before_drop_table_sec](../../operations/server-configuration-parameters/settings.md#database_atomic_delay_before_drop_table_sec).
Вы можете задать синхронный режим, определяя модификатор `SYNC`. Используйте для этого настройку [database_atomic_wait_for_drop_and_detach_synchronously](../../operations/settings/settings.md#database_atomic_wait_for_drop_and_detach_synchronously). В этом случае запрос `DROP` ждет завершения `SELECT`, `INSERT` и других запросов, которые используют таблицу. Таблица будет фактически удалена, когда она не будет использоваться.

### EXCHANGE TABLES/DICTIONARIES {#exchange-tables}

Запрос [EXCHANGE](../../sql-reference/statements/exchange.md) атомарно меняет местами две таблицы или два словаря. Например, вместо неатомарной операции:

```sql
RENAME TABLE new_table TO tmp, old_table TO new_table, tmp TO old_table;
```
вы можете использовать один атомарный запрос:

``` sql
EXCHANGE TABLES new_table AND old_table;
```

### ReplicatedMergeTree in Atomic Database {#replicatedmergetree-in-atomic-database}

Для таблиц [ReplicatedMergeTree](/engines/table-engines/mergetree-family/replication) рекомендуется не указывать параметры движка - путь в ZooKeeper и имя реплики. В этом случае будут использоваться параметры конфигурации: [default_replica_path](../../operations/server-configuration-parameters/settings.md#default_replica_path) и [default_replica_name](../../operations/server-configuration-parameters/settings.md#default_replica_name). Если вы хотите определить параметры движка явно, рекомендуется использовать макрос `{uuid}`. Это удобно, так как автоматически генерируются уникальные пути для каждой таблицы в ZooKeeper.

## Смотрите также

-   Системная таблица [system.databases](../../operations/system-tables/databases.md).
