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
* Be able to create a user authentication system
    * Know the user model's methods that are required for authentication
        * ```reset_session_token```, ```password=```, ```is_password?```, ```find_by_credentials```
* Know what it means to create and destroy a session
* Know how cookies and sessions interact in a ```current_user``` method
* Know how to access the current user from within a view

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

* ```CatRentalRequest#overlapping_requests``` gets all ```CatRentalRequest```s that overlap with the
one we are trying to validate.
* ```CatRentalRequest``` we are validating should not appear in list
of ```#overlapping_requests```
* The method returns the requests for the current ```Cat```
* This method runs on saved and unsaved ```CatRentalRequest```s
* Test Cases:
    * A cat rental request starting on 02/25/17 and ending on 02/27/17.
    * There is a overlap if another cat rental also starts on the same day (02/25/17).
    * There is a overlap if another cat rental request starts on the return day (02/27/17).
    * There is a overlap if another cat rental request starts between the start and end dates (02/26/17).

```
def overlapping_requests
        CatRentalRequest,
          where.not(id: self.id),
          where(cat_id: self.cat_id),
          where.not('start_date > :end_date OR end_date < :start_date',
                start_date: self.start_date, end_date: self.end_date)
 end
```

### Controller and New View
* ```CatRentalRequests``` Controller, resources in ```config/routes.rb```
* ```new.html.erb``` to create new requests
* A dropdown will allow user to select ```Cat```, with the form uploading a cat id.
* ```date``` input type selects start and end dates for request
* ```create``` action
* Cat show page will show existing requests

## Phase 3: Approving/Denying Requests

### ```approve!``` ```deny!``` methods
* Helper method CatRentalRequest#overlapping_pending_requests
* ```approve!``` changes ```CatRentalRequest``` instance status
from ```"PENDING"``` to ```"APPROVED"```
* ```save!``` instance into database, deny conflicting requests ```overlapping_pending_requests``` in
single Rails ```transaction```.
```
    def approve!
        CatRentalRequest.transaction do
           self.status = "APPROVED"
           self.save!
            # deny conflicting requests
           overlapping_pending_requests.each do |request|
            request.status = "DENIED"
            request.save!
           end
        end
    end
```
* ```deny!``` method changes ```CatRentalRequest``` instance status
from ```"PENDING"``` to ```DENIED```
```
   def deny!
        self.status = "DENIED"
        self.save!
    end
```
### Add Buttons
* ```Cat``` Show page has buttons to approve/deny rental requests.
* ```approve``` ```deny``` member routes for ```cat_rental_requests```
* Conditional logic will show/hide ```approve``` ```deny``` buttons
* ```CatRentalRequest#pending?``` boolean method
* CSS can be added to the currently existing view templates!

## Phase 4 - Users

### Add a ```User``` model
* ```User``` ```user_name``` and ```password_digest```
    * database constraints and model validations
* ```session_token``` column
    * ```presence: true``` and ```null: false```. ```after_iniitalize``` callback function will set token that is not already set.
* ```User#reset_session_token!``` method will use ```SecureRandom``` to generate a token.
* ```User#password=(password)``` setter method that writes the ```password_digest``` attribute with the hash of the given password.
* ```#is_password?(password)``` method verifies a password.
* ```::find_by_credentials(user_name, password)``` method returns the user with the given name if the password is correct.