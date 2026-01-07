create database online_shop;
use online_shop;

drop table if exists order_items;
drop table if exists orders;
drop table if exists products;
drop table if exists categories;
drop table if exists customers;

create table customers (
    customer_id int primary key auto_increment,
    customer_name varchar(100) not null,
    email varchar(100) not null unique,
    phone varchar(10) not null unique
);

create table categories (
    category_id int primary key auto_increment,
    category_name varchar(255) not null unique
);

create table products (
    product_id int primary key auto_increment,
    product_name varchar(255) not null unique,
    price decimal(10,2) not null check (price > 0),
    category_id int not null,
    foreign key (category_id) references categories(category_id)
);

create table orders (
    order_id int primary key auto_increment,
    customer_id int not null,
    order_date datetime default current_timestamp,
    status enum('Pending', 'Completed', 'Cancel') default 'Pending',
    foreign key (customer_id) references customers(customer_id)
);

create table order_items (
    order_item_id int primary key auto_increment,
    order_id int not null,
    product_id int not null,
    quantity int not null check (quantity > 0),
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);

insert into customers (customer_name, email, phone) values
('Nguyễn Văn An', 'an@gmail.com', '0901111111'),
('Trần Thị Bình', 'binh@gmail.com', '0902222222'),
('Lê Văn Cường', 'cuong@gmail.com', '0903333333'),
('Phạm Thị Dung', 'dung@gmail. com', '0904444444'),
('Hoàng Văn Em', 'em@gmail.com', '0905555555');

insert into categories (category_name) values
('Điện thoại'),
('Laptop'),
('Tai nghe'),
('Phụ kiện');

insert into products (product_name, price, category_id) values
('iPhone 15 Pro Max', 29990000, 1),
('Samsung Galaxy S24', 24990000, 1),
('MacBook Pro M3', 45990000, 2),
('Dell XPS 15', 35990000, 2),
('AirPods Pro', 5990000, 3),
('Sony WH-1000XM5', 7990000, 3),
('Ốp lưng iPhone', 299000, 4),
('Chuột Logitech MX Master', 2490000, 4),
('iPad Pro', 25990000, 1),
('Surface Pro 9', 28990000, 2);

insert into orders (customer_id, order_date, status) values
(1, '2024-01-10 10:30:00', 'Completed'),
(1, '2024-02-15 14:20:00', 'Completed'),
(2, '2024-01-20 09:15:00', 'Completed'),
(2, '2024-03-10 16:45:00', 'Pending'),
(3, '2024-02-01 11:00:00', 'Completed'),
(3, '2024-03-15 13:30:00', 'Cancel'),
(4, '2024-01-25 15:10:00', 'Completed'),
(5, '2024-02-20 10:00:00', 'Pending');

insert into order_items (order_id, product_id, quantity) values
(1, 1, 1),
(1, 5, 2),
(2, 3, 1),
(3, 2, 1),
(3, 7, 3),
(4, 6, 1),
(5, 4, 1),
(5, 8, 2),
(6, 9, 1),
(7, 10, 1),
(7, 6, 1),
(8, 5, 3);

select category_id, category_name from categories;

select order_id, customer_id, order_date, status from orders where status = 'Completed';

select product_id, product_name, price, category_id from products order by price desc;

select product_id, product_name, price from products order by price desc limit 5 offset 2;

select p.product_id, p.product_name, p.price, c.category_name from products p join categories c on p.category_id = c.category_id order by p.product_id;

select o.order_id, o.order_date, c.customer_name, o.status from orders o join customers c on o.customer_id = c.customer_id order by o.order_id;

select o.order_id, o.order_date, c.customer_name, o.status, sum(oi.quantity) as total_quantity from orders o join customers c on o.customer_id = c.customer_id join order_items oi on o.order_id = oi.order_id group by o.order_id, o.order_date, c.customer_name, o.status order by o.order_id;

select c.customer_id, c.customer_name, c.email, count(o.order_id) as total_orders from customers c left join orders o on c.customer_id = o.customer_id group by c.customer_id, c.customer_name, c.email order by count(o.order_id) desc;

select c.customer_id, c.customer_name, c.email, c.phone, count(o.order_id) as total_orders from customers c join orders o on c.customer_id = o.customer_id group by c.customer_id, c. customer_name, c.email, c.phone having count(o.order_id) >= 2 order by count(o.order_id) desc;

select c.category_id, c.category_name, count(p.product_id) as product_count, min(p.price) as min_price, max(p.price) as max_price, avg(p.price) as avg_price from categories c left join products p on c.category_id = p.category_id group by c.category_id, c.category_name order by c.category_id;

select product_id, product_name, price, (select avg(price) from products) as avg_price from products where price > (select avg(price) from products) order by price desc;

select customer_id, customer_name, email, phone from customers where customer_id in (select distinct customer_id from orders);

select customer_id, customer_name, email, phone from customers c where exists (select 1 from orders o where o.customer_id = c.customer_id);

select o.order_id, c.customer_name, o.order_date, o.status, sum(oi.quantity) as total_quantity from orders o join customers c on o.customer_id = c.customer_id join order_items oi on o.order_id = oi.order_id group by o.order_id, c.customer_name, o.order_date, o.status having sum(oi.quantity) = (select max(total_quantity) from (select sum(quantity) as total_quantity from order_items group by order_id) as order_totals);

select distinct c.customer_name, c. email from customers c join orders o on c.customer_id = o. customer_id join order_items oi on o. order_id = oi.order_id join products p on oi.product_id = p.product_id where p.category_id = (select category_id from products group by category_id order by avg(price) desc limit 1);

select customer_id, customer_name, total_quantity from (select c.customer_id, c.customer_name, sum(oi. quantity) as total_quantity from customers c join orders o on c.customer_id = o.customer_id join order_items oi on o.order_id = oi. order_id group by c.customer_id, c.customer_name) as customer_purchases order by total_quantity desc;

select product_id, product_name, price from products where price = (select max(price) from products);

select product_id, product_name, price from products where price = (select price from products order by price desc limit 1);