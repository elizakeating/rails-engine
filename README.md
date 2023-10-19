# Building an API in Rails

## Merchant endpoints
* get `/api/v1/merchants` - get all merchants
* get `/api/v1/merchants/:id` - get a certain merchant
* get `/api/v1/merchants/:id/items` - gets all items for a specific merchant
* get `/api/v1/merchants/find?name=<query>` - finds all merchants based off of a case insensitive search

## Items endpoints
* get `/api/v1/items` - get all items
* get `/api/v1/items/:id` - get a certain item
* get `/api/v1/items/:id/merchant` - get the merchant for a specific item
* post `/api/v1/items/` - create an item, body can only have the following fields:<br>
```
{
 "name": "value1",
 "description": "value2",
 "unit_price": 100.99,
 "merchant_id": 14
}
```
* patch `/api/v1/items/:id` - update a specific item, body needs to follow the same pattern above
* delete `/api/v1/items/:id` - delete a specific item
* get `/api/v1/items/find?name=<name>` - finds one item based off of a case insensitive search in alphabetical order
* get `/api/v1/items/find?min_price=<number>` - finds one item that is greater than the min price in alphabetical order
* get `/api/v1/items/find?max_price=<number>` - finds one item that is less than the min price in alphabetical order
* get `/api/v1/items/find?min_price=<number>&max_price=<number>` - finds one item in the price range in alphabetical order
## You can not search for a name and max/min/both prices at the same time.
