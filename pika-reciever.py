#!/usr/bin/env python
import pika

credentials = pika.PlainCredentials('', '')

connection = pika.BlockingConnection(
        pika.ConnectionParameters('host',
                                   5672,
                                   '/',
                                   credentials))
channel = connection.channel()

channel.exchange_declare(exchange='', exchange_type='topic', durable=True)

result = channel.queue_declare(queue='', exclusive=True)
queue_name = result.method.queue

channel.queue_bind(exchange='', queue=queue_name, routing_key='true.#')

print(' [*] Waiting for logs. To exit press CTRL+C')

def callback(ch, method, properties, body):
    print(" [x] %r" % body)

channel.basic_consume(
    queue=queue_name, on_message_callback=callback, auto_ack=True)

channel.start_consuming()
