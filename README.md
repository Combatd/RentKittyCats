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

### Index/Show Pages
* ```class CatsController < ApplicationController```
* ```index``` page of all ```Cat```s
    * Lists the cats and links to the show pages.
* ```show``` page for one cat
    * Shows the cat's attributes
    * A ```table``` element with ```tr```, ```td```, ```th``` tags will
    format the cat's information.
* ```_form``` form partial utilized in ```index``` and ```show```
    * ```cat``` local variable takes value of ```@cat```
    * ```edit``` makes a PATCH request

## Phase 2 - CatRentalRequest

### Model
* ```CatRentalRequest``` schema and model
    * ```cat_id``` (integer)
    * ```start_date``` (date)
    * ```end_date``` (date)
    * ```status``` (string), ```default: 'PENDING'```, can switch to
        ```'APPROVED'``` or ```'DENIED'``` 
* inclusion validates ```status```
* ```null: false``` constraints, ```presence: true``` validations
* Associations between ```CatRentalRequest``` and ```Cat```
* ```dependent: :destroy``` prevents widowed ```CatRentalRequest``` upon destroying ```Cat```

### Custom Validation
```CatRentalRequests``` should not be valid if they overlap with an approved ```CatRentalRequest``` for the same cat. A single cat can't be rented out to two people at once!