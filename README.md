# RentKittyCats

This project is a rental website based on 99dresses, but oriented around cats! It allows users to rent out their cats to other users, and the renters can accept / deny requests. Once a request has been accepted, overlapping requests are automatically denied, preventing new requests for that duration of time.

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

### ```UsersController```, ```SessionsController```
We need a ```UsersController``` with ```new```/```create``` actions and routes.
Then we can build a ```SessionsController``` for authorization.
* ```:session``` resource in ```routes.rb```
    * ```new```, ```create```, ```destroy``` actions/resources
* ```SessionsController#new``` needs ```new.html.erb```
* ```SessionsController#create```
    * Verify ```user_name/password```
    * Reset ```User```'s ```session_token```
    * ```session``` hash updated with ```session_token```
    * Redirect user to ```CatsController#index```
* Create all remaining views for these controllers.

### Using the session
* ```ApplicationController#current_user``` looks up user with current session token
    * ```helper_method :current_user``` makes it available in views
* ```SessionsController#destroy```
    * ```#reset_session_token``` called on ```current_user``` invalidates the old token if there is a ```current_user```, making sure that no one can steal the old token and login with it.
    * ```:session_token``` is blanked out in the ```session``` hash
* ```application.html.erb``` has a header at the top
    * Shows username if signed in
    * Shows login or logout button depending if a user is signed in
* A new user logs in as soon as they register.
* ```SessionsController#create``` factored out into ```ApplicationController#login_user!``` method to be used in ```UsersController```
* In ```UsersController``` and ```SessionsController```, ```before_action``` callback redirects user to Cats index if the user tries to visit login/signup pages when already signed in.

## Phase 5: Use ```current_user``` with ```Cat``` and ```CatRentalRequest```

### Cats have an owner
* ```user_id``` column on cats, index on ```user_id```
* ```User``` has many ```cats``` (Owner has cat)
* ```owner``` presence validation (not null)
* ```CatsController#create``` ```user_id``` is set to ```current_user.id```

The form submitter must be logged in or they couldn't view the form to begin with, so we can set cat.owner to the current_user without relying on any form inputs.

* In the ```CatsController#edit``` ```CatsController#update``` actions,```before_action :user_owns_cat, only: [:edit, :update]```
    * Instead of using Cat.find, search for the cat among only the ```current_user```'s cats with the ```User#cats``` association.
    * Do a ```redirect_to``` in the filter if the user is not authorized.
    * Redirection from inside a ```before_action``` cancels further processing of the request. The action will never be called.
* On ```CatRentalRequestsController``` only the cat owner should be able to approve/deny.
* On the Cat Show page, does not show the approve/deny buttons unless the user owns the cat.

### CatRentalRequests have a requester
* ```user_id``` column on ```CatRentalRequest``` records ID of requester
    * index on foreign_key ```user_id```
    * ```CatRentalRequest``` ```belongs_to``` ```User``` ```has_many```
    * ```validates``` ```:requester``` on ```CatRentalRequest```
* ```current_user``` is ```requester``` on ```CatRentalRequestController```
* ```requester``` is displayed to each rental request on Cat Show Page