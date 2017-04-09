#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
from cos_cred import CredInfo
from cos_config import CosConfig
from cos_op import FileOp
from cos_op import FolderOp
from cos_request import UploadFileRequest
from cos_request import UploadSliceFileRequest
from cos_request import UpdateFileRequest
from cos_request import UpdateFolderRequest
from cos_request import DelFileRequest
from cos_request import DelFolderRequest
from cos_request import CreateFolderRequest
from cos_request import StatFolderRequest
from cos_request import StatFileRequest
from cos_request import ListFolderRequest
from cos_request import DownloadFileRequest
try:
    from requests.packages.urllib3.exceptions import InsecureRequestWarning
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
except ImportError:
    pass


class CosClient(object):
    """Cos客户端类"""

    def __init__(self, appid, secret_id, secret_key, region="shanghai"):
        """ 设置用户的相关信息

        :param appid: appid
        :param secret_id: secret_id
        :param secret_key: secret_key
        """
        self._cred = CredInfo(appid, secret_id, secret_key)
        self._config = CosConfig(region=region)
        self._http_session = requests.session()
        self._file_op = FileOp(self._cred, self._config, self._http_session)
        self._folder_op = FolderOp(self._cred, self._config, self._http_session)

    def set_config(self, config):
        """设置config"""
        assert isinstance(config, CosConfig)
        self._config = config
        self._file_op.set_config(config)
        self._folder_op.set_config(config)

    def get_config(self):
        """获取config"""
        return self._config

    def set_cred(self, cred):
        """设置用户的身份信息

        :param cred:
        :return:
        """
        assert isinstance(cred, CredInfo)
        self._cred = cred
        self._file_op.set_cred(cred)
        self._folder_op.set_cred(cred)

    def get_cred(self):
        """获取用户的相关信息

        :return:
        """
        return self._cred

    def upload_file(self, request):
        """ 上传文件(自动根据文件大小，选择上传策略, 强烈推荐使用),上传策略: 8MB以下适用单文件上传, 8MB(含)适用分片上传

        :param request:
        :return:
        """
        assert isinstance(request, UploadFileRequest)
        return self._file_op.upload_file(request)

    def upload_single_file(self, request):
        """单文件上传接口, 适用用小文件8MB以下, 最大不得超过20MB, 否则会返回参数错误

        :param request:
        :return:
        """
        assert isinstance(request, UploadFileRequest)
        return self._file_op.upload_single_file(request)

    def upload_slice_file(self, request):
        """ 分片上传接口, 适用于大文件8MB及以上

        :param request:
        :return:
        """
        assert isinstance(request, UploadSliceFileRequest)
        return self._file_op.upload_slice_file(request)

    def del_file(self, request):
        """ 删除文件

        :param request:
        :return:
        """
        assert isinstance(request, DelFileRequest)
        return self._file_op.del_file(request)

    def move_file(self, request):
        return self._file_op.move_file(request)

    def stat_file(self, request):
        """获取文件属性

        :param request:
        :return:
        """
        assert isinstance(request, StatFileRequest)
        return self._file_op.stat_file(request)

    def update_file(self, request):
        """更新文件属性

        :param request:
        :return:
        """
        assert isinstance(request, UpdateFileRequest)
        return self._file_op.update_file(request)

    def download_file(self, request):
        assert isinstance(request, DownloadFileRequest)
        return self._file_op.download_file(request)

    def create_folder(self, request):
        """创建目录

        :param request:
        :return:
        """
        assert isinstance(request, CreateFolderRequest)
        return self._folder_op.create_folder(request)

    def del_folder(self, request):
        """删除目录

        :param request:
        :return:
        """
        assert isinstance(request, DelFolderRequest)
        return self._folder_op.del_folder(request)

    def stat_folder(self, request):
        """获取folder属性请求

        :param request:
        :return:
        """
        assert isinstance(request, StatFolderRequest)
        return self._folder_op.stat_folder(request)

    def update_folder(self, request):
        """更新目录属性

        :param request:
        :return:
        """
        assert isinstance(request, UpdateFolderRequest)
        return self._folder_op.update_folder(request)

    def list_folder(self, request):
        """获取目录下的文件和目录列表

        :param request:
        :return:
        """
        assert isinstance(request, ListFolderRequest)
        return self._folder_op.list_folder(request)
