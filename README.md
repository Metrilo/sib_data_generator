# sib_data_generator

Start with installing the deps
```bundle install```

Then generate the orders
```ruby main.rb```

In `main.rb` there are few configs that could be done

Currently, everything is written in two files - one for ClickHouse (creating `events` databse and `order` table if they don't exists) and one for the new SiB orders API in JSON format following the structure

```
{
  result: [
    {
      "id": "#100",
      "status": "placed",
      "amount": 413.14,
      "createdAt": "2019-01-01T07:59:45+02:00",
      "updatedAt": "2019-01-01T07:59:45+02:00",
      "products": [
        { "productId": "55397-alfye", "quantity": 2 },
        { "productId": "37632-mieue", "quantity": 2, "variantId": "51351-gidxt" }
      ],
      "email": "jeramy@tromp.biz",
      "billing": { 
        "address": "43411 Braun Circle",
        "city": "Gerrybury",
        "countryCode": "GE",
        "phone": "(114) 585-7601",
        "postcode": "07366-7886",
        "paymentMethod": "Pay Pal",
        "region": "Florida"
      },
      "coupons": ["WINTER","30OFF"]
    },....
  ]
}
```