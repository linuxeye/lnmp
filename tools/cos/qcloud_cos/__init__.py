#!/usr/bin/env python
# -*- coding: utf-8 -*-
from .cos_client import CosClient
from .cos_client import CosConfig
from .cos_client import CredInfo
from .cos_request import UploadFileRequest
from .cos_request import UploadSliceFileRequest
from .cos_request import UpdateFileRequest
from .cos_request import UpdateFolderRequest
from .cos_request import DelFolderRequest
from .cos_request import DelFileRequest
from .cos_request import CreateFolderRequest
from .cos_request import StatFileRequest
from .cos_request import StatFolderRequest
from .cos_request import ListFolderRequest
from .cos_request import DownloadFileRequest
from .cos_request import MoveFileRequest
from .cos_auth import Auth
from .cos_cred import CredInfo


import logging

try:
    from logging import NullHandler
except ImportError:
    class NullHandler(logging.Handler):
        def emit(self, record):
            pass

logging.getLogger(__name__).addHandler(NullHandler())
