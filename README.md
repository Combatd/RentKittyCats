# RentKittyCats

This project is a rental website based on 99dresses, but oriented around cats!

## Learning Goals
* Be able to build a model with validations and default values
* Know how to build Rails views for new and edit forms
    * Know how to use a hidden field to set the form's method
    * Be able to separate the form out into a partial that both forms use
    * Be able to show data and actions based on the form's type
    * Know how to use select and input HTML elements

* Be able to add methods to a Rails model

## Phase 1 - Cat

### Model
* ```birth_date```
* ```color```
* ```name```
* ```sex```
* ```description```
    * ```text``` column describes memories the user has with ```Cat```
* Timestamps
* database-level NOT NULL constraints ```null: false``` and model-level presence validations ```presence: true```