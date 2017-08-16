from django.core.management.base import BaseCommand, CommandError
from boto.s3.connection import S3Connection, Bucket, Key
from django.conf import settings
from ai_pics.models import AIPics, AIAttachment
from sets import Set
from django.db import connection

class Command(BaseCommand):
    help = 'Deletes empty AI pics'

    def handle(self, *args, **options):
        conn = S3Connection(settings.AWS_ACCESS_KEY_ID, settings.AWS_SECRET_ACCESS_KEY)
        bucket = Bucket(conn, settings.AWS_STORAGE_BUCKET_AI_NAME)

        s3_files = Set()
        for key in bucket.list():
            s3_files.add(key.name)

        attachments = AIAttachment.objects.select_related('ai_pics')\
            .order_by('-ai_pics_aipics.created_at')
        for attachment in attachments:
            if attachment.attachment not in s3_files:
                print attachment.attachment
                attachment.delete()

        with connection.cursor() as cursor:
            cursor.execute(
                'delete from ai_pics_aipics WHERE '
                '(select count(*) from ai_pics_aiattachment where ai_pics_id=ai_pics_aipics.id) =0'
            )