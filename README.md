# README
Actualizado Lunes 9 de diciembre.

## Back-End Test Runa HR:  Sistema de registros!

Este repositorio contiene el desarrollo de una API que permite almacenar el registro de entrada y salida de los  empleados en una empresa. La API cumple con las siguientes funcionalidades.

- Inicio de sesión de administrador de la empresa,  Inicio de sesión de empleado  
**/api/v1/auth/login**
- El administrador puede marcar la entrada y salida de sus empleados  
**/api/v1/admin/logs/check_in**
**/api/v1/admin/logs/check_out**
- El administrador gestione los reportes de entrada y salida de sus empleados  
**/api/v1/admin/logs/report**
- El administrador gestione la información de empleados  
> El admin tiene el crud completo para gestionar los  usuarios, mientras que el empleado solo puede hacer show (de el mismo) update_password y ver el reporte de el mismo
- El empleado revise su reporte de entrada y salida  
> puede ver reporte de el mismo unicamente

## Documantación
https://documenter.getpostman.com/view/4170294/SWE6ZxFV?version=latest

# Como probar la API

###  Test de forma local:
Para probar el API de forma local se debe clonar el  Repositorio  y ejecutar el set de pruebas realizado con Rspec
> run $ bundle install
> run $ rails db:create & $ rails db:migrate & $ rails db:seed
> run $ bundle exec rspec spec/

Este debe ser el resultado esperado:
> Finished in 2 seconds (files took 1.76 seconds to load)
81 examples, 0 failures, 8 pending


### Test manual en el entorno de desarrollo o produccion:
#### Requerimientos:
  **Postman :**  The collaboration platform for API development https://www.getpostman.com/

  La aplicacion se encuentra desplegada en heroku en el siguiente endpoint: https://runa-hr-test.herokuapp.com/

Para probar la API de forma sencilla se construyo una collecion de request en Postman que se puede importar del siguiente link:
> https://www.getpostman.com/collections/14ecc993633a5f1a8fbe

En la descripcion que se encuentra en la documentacion se presenta un protocolo de pruebas para consumir todos los endpoints de la applicacion.

### Authentication
La autenticacion se realiza por medio de Json Web Tokens y los cuales son generados por la API y enviados al usuario en el endpoint api/v1/auth/login

Dentro de las variables de la coleciccion de postman (que se pueden encontrar al ir a editar la coleccion, en el tab de variables) se pueden editar los campos para las variables  
**{{authorization_token}}** y **{{production_authorization_token}}**.
