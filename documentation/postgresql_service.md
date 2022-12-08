# postgresql_service

[Back to resource list](../README.md#resources)

## Actions

- `:start`
- `:stop`
- `:restart`
- `:reload`
- `:enable`
- `:disable`

## Properties

| Name           | Name? | Type        | Default | Description                          | Allowed Values |
| -------------- | ----- | ----------- | ------- | ------------------------------------ | -------------- |
| `service_name` |       | String      |         | Service name to perform actions for  |                |
| `delay_start`  |       | true, false |         | Delay service start until end of run |                |

## Libraries

- `PostgreSQL::Cookbook::Helpers`
