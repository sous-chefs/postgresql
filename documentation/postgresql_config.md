# postgresql_config

[Back to resource list](../README.md#resources)

## Requires

- `deepsort`

## Uses

- [partial/_config_file](partial/_config_file.md)

## Actions

- `:create`
- `:delete`

## Properties

| Name                | Name? | Type            | Default | Description | Allowed Values |
| ------------------- | ----- | --------------- | ------- | ----------- | -------------- |
| `config_file`       |       | String          |         |             |                |
| `source`            |       | String          |         |             |                |
| `version`           |       | String, Integer |         |             |                |
| `data_directory`    |       | String          |         |             |                |
| `hba_file`          |       | String          |         |             |                |
| `ident_file`        |       | String          |         |             |                |
| `external_pid_file` |       | String          |         |             |                |
| `server_config`     |       | Hash            |         |             |                |
