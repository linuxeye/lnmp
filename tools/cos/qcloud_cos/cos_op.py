#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import time
import json
import hashlib
import urllib
from contextlib import closing
import cos_auth
from cos_err import CosErr
from cos_request import UploadFileRequest
from cos_request import UploadSliceFileRequest
from cos_request import UpdateFileRequest
from cos_request import DelFileRequest
from cos_request import StatFileRequest
from cos_request import CreateFolderRequest
from cos_request import UpdateFolderRequest
from cos_request import StatFolderRequest
from cos_request import DelFolderRequest
from cos_request import ListFolderRequest, DownloadFileRequest, MoveFileRequest
from cos_common import Sha1Util

from logging import getLogger
from traceback import format_exc

logger = getLogger(__name__)


class BaseOp(object):
    """
    BaseOp基本操作类型
    """

    def __init__(self, cred, config, http_session):
        """ 初始化类

        :param cred: 用户的身份信息
        :param config: cos_config配置类
        :param http_session: http 会话
        """
        self._cred = cred
        self._config = config
        self._http_session = http_session
        self._expired_period = self._config.get_sign_expired()

    def set_cred(self, cred):
        """设置用户的身份信息

        :param cred:
        :return:
        """
        self._cred = cred

    def set_config(self, config):
        """ 设置config

        :param config:
        :return:
        """
        self._config = config
        self._expired_period = self._config.get_sign_expired()

    def _build_url(self, bucket, cos_path):
        """生成url

        :param bucket:
        :param cos_path:
        :return:
        """
        bucket = bucket.encode('utf8')
        end_point = self._config.get_endpoint().rstrip('/').encode('utf8')
        appid = self._cred.get_appid()
        cos_path = urllib.quote(cos_path.encode('utf8'), '~/')
        url = '%s/%s/%s%s' % (end_point, appid, bucket, cos_path)
        return url

    def build_download_url(self, bucket, cos_path, sign):
        # Only support http now
        appid = self._cred.get_appid()
        hostname = self._config.get_download_hostname()
        cos_path = urllib.quote(cos_path)
        url_tmpl = 'http://{bucket}-{appid}.{hostname}{cos_path}?sign={sign}'

        return url_tmpl.format(bucket=bucket, appid=appid, hostname=hostname, cos_path=cos_path, sign=sign)

    def send_request(self, method, bucket, cos_path, **kwargs):
        """ 发送http请求

        :param method:
        :param bucket:
        :param cos_path:
        :param args:
        :return:
        """
        url = self._build_url(bucket, cos_path)
        logger.debug("sending request, method: %s, bucket: %s, cos_path: %s" % (method, bucket, cos_path))

        try:
            if method == 'POST':
                http_resp = self._http_session.post(url, verify=False, **kwargs)
            else:
                http_resp = self._http_session.get(url, verify=False, **kwargs)

            status_code = http_resp.status_code
            if status_code < 500:
                return http_resp.json()
            else:
                logger.warning("request failed, response message: %s" % http_resp.text)
                err_detail = 'url:%s, status_code:%d' % (url, status_code)
                return CosErr.get_err_msg(CosErr.NETWORK_ERROR, err_detail)
        except Exception as e:
            logger.exception("request failed, return SERVER_ERROR")
            err_detail = 'url:%s, exception:%s traceback:%s' % (url, str(e), format_exc())
            return CosErr.get_err_msg(CosErr.SERVER_ERROR, err_detail)

    def _check_params(self, request):
        """检查用户输入参数, 检查通过返回None, 否则返回一个代表错误原因的dict

        :param request:
        :return:
        """
        if not self._cred.check_params_valid():
            return CosErr.get_err_msg(CosErr.PARAMS_ERROR, self._cred.get_err_tips())
        if not request.check_params_valid():
            return CosErr.get_err_msg(CosErr.PARAMS_ERROR, request.get_err_tips())
        return None

    def del_base(self, request):
        """删除文件或者目录, is_file_op为True表示是文件操作

        :param request:
        :return:
        """
        check_params_ret = self._check_params(request)
        if check_params_ret is not None:
            return check_params_ret

        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        sign = auth.sign_once(bucket, cos_path)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['Content-Type'] = 'application/json'
        http_header['User-Agent'] = self._config.get_user_agent()

        http_body = {'op': 'delete'}

        timeout = self._config.get_timeout()
        return self.send_request('POST', bucket, cos_path, headers=http_header, data=json.dumps(http_body), timeout=timeout)

    def stat_base(self, request):
        """获取文件和目录的属性

        :param request:
        :return:
        """
        check_params_ret = self._check_params(request)
        if check_params_ret is not None:
            return check_params_ret

        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        expired = int(time.time()) + self._expired_period
        sign = auth.sign_more(bucket, cos_path, expired)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['User-Agent'] = self._config.get_user_agent()

        http_body = dict()
        http_body['op'] = 'stat'

        timeout = self._config.get_timeout()
        return self.send_request('GET', bucket, cos_path, headers=http_header, params=http_body, timeout=timeout)


class FileOp(BaseOp):
    """FileOp 文件相关操作"""

    def __init__(self, cred, config, http_session):
        """ 初始化类

        :param cred: 用户的身份信息
        :param config: cos_config配置类
        :param http_session: http 会话
        """
        BaseOp.__init__(self, cred, config, http_session)
        # 单文件上传的最大上限是20MB
        self.max_single_file = 20 * 1024 * 1024

    @staticmethod
    def _sha1_content(content):
        """获取content的sha1

        :param content:
        :return:
        """
        sha1_obj = hashlib.sha1()
        sha1_obj.update(content)
        return sha1_obj.hexdigest()

    def update_file(self, request):
        """更新文件

        :param request:
        :return:
        """
        assert isinstance(request, UpdateFileRequest)
        logger.debug("request: " + str(request.get_custom_headers()))
        check_params_ret = self._check_params(request)
        if check_params_ret is not None:
            return check_params_ret

        logger.debug("params verify successfully")
        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        sign = auth.sign_once(bucket, cos_path)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['Content-Type'] = 'application/json'
        http_header['User-Agent'] = self._config.get_user_agent()

        http_body = dict()
        http_body['op'] = 'update'

        if request.get_biz_attr() is not None:
            http_body['biz_attr'] = request.get_biz_attr()

        if request.get_authority() is not None:
            http_body['authority'] = request.get_authority()

        if request.get_custom_headers() is not None and len(request.get_custom_headers()) is not 0:
            http_body['custom_headers'] = request.get_custom_headers()
        logger.debug("Update Request Header: " + json.dumps(http_body))
        timeout = self._config.get_timeout()
        return self.send_request('POST', bucket, cos_path, headers=http_header, data=json.dumps(http_body), timeout=timeout)

    def del_file(self, request):
        """删除文件

        :param request:
        :return:
        """
        assert isinstance(request, DelFileRequest)
        return self.del_base(request)

    def stat_file(self, request):
        """获取文件的属性

        :param request:
        :return:
        """
        assert isinstance(request, StatFileRequest)
        return self.stat_base(request)

    def upload_file(self, request):
        """上传文件, 根据用户的文件大小,选择单文件上传和分片上传策略

        :param request:
        :return:
        """
        assert isinstance(request, UploadFileRequest)
        check_params_ret = self._check_params(request)
        if check_params_ret is not None:
            return check_params_ret

        local_path = request.get_local_path()
        file_size = os.path.getsize(local_path)

        suit_single_file_zie = 8 * 1024 * 1024
        if file_size < suit_single_file_zie:
            return self.upload_single_file(request)
        else:
            bucket = request.get_bucket_name()
            cos_path = request.get_cos_path()
            local_path = request.get_local_path()
            slice_size = 1024 * 1024
            biz_attr = request.get_biz_attr()
            upload_slice_request = UploadSliceFileRequest(bucket, cos_path, local_path, slice_size, biz_attr)
            upload_slice_request.set_insert_only(request.get_insert_only())
            return self.upload_slice_file(upload_slice_request)

    def upload_single_file(self, request):
        """ 单文件上传

        :param request:
        :return:
        """
        assert isinstance(request, UploadFileRequest)
        check_params_ret = self._check_params(request)
        if check_params_ret is not None:
            return check_params_ret

        local_path = request.get_local_path()
        file_size = os.path.getsize(local_path)
        # 判断文件是否超过单文件最大上限, 如果超过则返回错误
        # 并提示用户使用别的接口
        if file_size > self.max_single_file:
            return CosErr.get_err_msg(CosErr.NETWORK_ERROR, 'file is too big, please use upload_file interface')

        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        expired = int(time.time()) + self._expired_period
        sign = auth.sign_more(bucket, cos_path, expired)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['User-Agent'] = self._config.get_user_agent()

        with open(local_path, 'rb') as f:
            file_content = f.read()

        http_body = dict()
        http_body['op'] = 'upload'
        http_body['filecontent'] = file_content
        http_body['sha'] = FileOp._sha1_content(file_content)
        http_body['biz_attr'] = request.get_biz_attr()
        http_body['insertOnly'] = str(request.get_insert_only())

        timeout = self._config.get_timeout()
        ret = self.send_request('POST', bucket, cos_path, headers=http_header, files=http_body, timeout=timeout)

        if request.get_insert_only() != 0:
            return ret

        if ret[u'code'] == 0:
            return ret

        # try to delete object, and re-post request
        del_request = DelFileRequest(bucket_name=request.get_bucket_name(), cos_path=request.get_cos_path())
        ret = self.del_file(del_request)
        if ret[u'code'] == 0:
            return self.send_request('POST', bucket, cos_path, headers=http_header, files=http_body, timeout=timeout)
        else:
            return ret

    def _upload_slice_file(self, request):
        assert isinstance(request, UploadSliceFileRequest)
        check_params_ret = self._check_params(request)
        if check_params_ret is not None:
            return check_params_ret

        local_path = request.get_local_path()
        slice_size = request.get_slice_size()
        enable_sha1 = request.enable_sha1

        if enable_sha1 is True:
            sha1_by_slice_list = Sha1Util.get_sha1_by_slice(local_path, slice_size)
            request.sha1_list = sha1_by_slice_list
            request.sha1_content = sha1_by_slice_list[-1]["datasha"]
        else:
            request.sha1_list = None
            request.sha1_content = None

        control_ret = self._upload_slice_control(request)

        # 表示控制分片已经产生错误信息
        if control_ret[u'code'] != 0:
            return control_ret

        # 命中秒传
        if u'access_url' in control_ret[u'data']:
            return control_ret

        local_path = request.get_local_path()
        file_size = os.path.getsize(local_path)
        if u'slice_size' in control_ret[u'data']:
            slice_size = control_ret[u'data'][u'slice_size']
        offset = 0
        session = control_ret[u'data'][u'session']
        # ?concurrency
        if request._max_con <= 1 or (
                u'serial_upload' in control_ret[u'data'] and control_ret[u'data'][u'serial_upload'] == 1):

            logger.info("upload file serially")
            slice_idx = 0
            with open(local_path, 'rb') as local_file:

                while offset < file_size:
                    file_content = local_file.read(slice_size)

                    data_ret = self._upload_slice_data(request, file_content, session, offset)

                    if data_ret[u'code'] == 0:
                        if u'access_url' in data_ret[u'data']:
                            return data_ret
                    else:
                        return data_ret

                    offset += slice_size
                    slice_idx += 1
        else:
            logger.info('upload file concurrently')
            from threadpool import SimpleThreadPool
            pool = SimpleThreadPool(request._max_con)

            slice_idx = 0
            with open(local_path, 'rb') as local_file:

                while offset < file_size:
                    file_content = local_file.read(slice_size)

                    pool.add_task(self._upload_slice_data, request, file_content, session, offset)

                    offset += slice_size
                    slice_idx += 1

            pool.wait_completion()
            result = pool.get_result()
            if not result['success_all']:
                return {u'code': 1, u'message': str(result)}

        data_ret = self._upload_slice_finish(request, session, file_size)
        return data_ret

    def upload_slice_file(self, request):
        """分片文件上传(串行)

        :param request:
        :return:
        """
        ret = self._upload_slice_file(request)

        if ret[u'code'] == 0:
            return ret

        if request.get_insert_only() == 0:
            del_request = DelFileRequest(request.get_bucket_name(), request.get_cos_path())
            ret = self.del_file(del_request)
            if ret[u'code'] == 0:
                return self._upload_slice_file(request)
            else:
                return ret
        else:
            return ret

    def _upload_slice_finish(self, request, session, filesize):
        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        expired = int(time.time()) + self._expired_period
        sign = auth.sign_more(bucket, cos_path, expired)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['User-Agent'] = self._config.get_user_agent()

        http_body = dict()
        http_body['op'] = "upload_slice_finish"
        http_body['session'] = session
        http_body['filesize'] = str(filesize)
        if request.sha1_list is not None:
            http_body['sha'] = request.sha1_list[-1]["datasha"]
        timeout = self._config.get_timeout()

        return self.send_request('POST', bucket, cos_path, headers=http_header, files=http_body, timeout=timeout)

    def _upload_slice_control(self, request):
        """串行分片第一步, 上传控制分片

        :param request:
        :return:
        """
        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        expired = int(time.time()) + self._expired_period
        sign = auth.sign_more(bucket, cos_path, expired)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['User-Agent'] = self._config.get_user_agent()

        local_path = request.get_local_path()
        file_size = os.path.getsize(local_path)
        slice_size = request.get_slice_size()
        biz_atrr = request.get_biz_attr()

        http_body = dict()
        http_body['op'] = 'upload_slice_init'
        if request.enable_sha1:
            http_body['sha'] = request.sha1_list[-1]["datasha"]
            http_body['uploadparts'] = json.dumps(request.sha1_list)
        http_body['filesize'] = str(file_size)
        http_body['slice_size'] = str(slice_size)
        http_body['biz_attr'] = biz_atrr
        http_body['insertOnly'] = str(request.get_insert_only())

        timeout = self._config.get_timeout()
        return self.send_request('POST', bucket, cos_path, headers=http_header, files=http_body, timeout=timeout)

    def _upload_slice_data(self, request, file_content, session, offset, retry=3):
        """串行分片第二步, 上传数据分片

        :param request:
        :param file_content:
        :param session:
        :param offset:
        :return:
        """
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        auth = cos_auth.Auth(self._cred)
        expired = int(time.time()) + self._expired_period
        sign = auth.sign_more(bucket, cos_path, expired)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['User-Agent'] = self._config.get_user_agent()

        http_body = dict()
        http_body['op'] = 'upload_slice_data'
        http_body['filecontent'] = file_content
        http_body['session'] = session
        http_body['offset'] = str(offset)
        if request.sha1_content is not None:
            http_body['sha'] = request.sha1_content

        timeout = self._config.get_timeout()

        for _ in range(retry):
            ret = self.send_request('POST', bucket, cos_path, headers=http_header, files=http_body, timeout=timeout)
            if ret['code'] == 0:
                return ret
        else:
            return ret

    def __download_url(self, uri, filename, headers):
        session = self._http_session

        with closing(session.get(uri, stream=True, timeout=30, headers=headers)) as ret:
            if ret.status_code in [200, 206]:

                if 'Content-Length' in ret.headers:
                    content_len = int(ret.headers['Content-Length'])
                else:
                    raise IOError("download failed without Content-Length header")

                file_len = 0
                with open(filename, 'wb') as f:
                    for chunk in ret.iter_content(chunk_size=1024):
                        if chunk:
                            file_len += len(chunk)
                            f.write(chunk)
                    f.flush()
                if file_len != content_len:
                    raise IOError("download failed with incomplete file")
            else:
                raise IOError("download failed with status code:" + str(ret.status_code))

    def download_file(self, request):
        assert isinstance(request, DownloadFileRequest)

        auth = cos_auth.Auth(self._cred)
        sign = auth.sign_download(request.get_bucket_name(), request.get_cos_path(), self._config.get_sign_expired())
        url = self.build_download_url(request.get_bucket_name(), request.get_cos_path(), sign)
        logger.info("Uri is %s" % url)
        try:
            self.__download_url(url, request._local_filename, request._custom_headers)
            return {u'code': 0, u'message': "download successfully"}
        except Exception as e:
            return {u'code': 1, u'message': "download failed, exception: " + str(e)}

    def __move_file(self, request):

        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        sign = auth.sign_once(bucket, cos_path)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['User-Agent'] = self._config.get_user_agent()

        http_body = dict()
        http_body['op'] = 'move'
        http_body['dest_fileid'] = request.dest_path
        http_body['to_over_write'] = str(1 if request.overwrite else 0)

        timeout = self._config.get_timeout()
        return self.send_request('POST', bucket, cos_path, headers=http_header, params=http_body, timeout=timeout)

    def move_file(self, request):

        assert isinstance(request, MoveFileRequest)
        return self.__move_file(request)


class FolderOp(BaseOp):
    """FolderOp 目录相关操作"""
    def __init__(self, cred, config, http_session):
        BaseOp.__init__(self, cred, config, http_session)

    def update_folder(self, request):
        """更新目录

        :param request:
        :return:
        """
        assert isinstance(request, UpdateFolderRequest)
        check_params_ret = self._check_params(request)
        if check_params_ret is not None:
            return check_params_ret

        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        sign = auth.sign_once(bucket, cos_path)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['Content-Type'] = 'application/json'
        http_header['User-Agent'] = self._config.get_user_agent()

        http_body = dict()
        http_body['op'] = 'update'
        http_body['biz_attr'] = request.get_biz_attr()

        timeout = self._config.get_timeout()
        return self.send_request('POST', bucket, cos_path, headers=http_header, data=json.dumps(http_body), timeout=timeout)

    def del_folder(self, request):
        """删除目录

        :param request:
        :return:
        """
        assert isinstance(request, DelFolderRequest)
        return self.del_base(request)

    def stat_folder(self, request):
        """获取目录属性

        :param request:
        :return:
        """
        assert isinstance(request, StatFolderRequest)
        return self.stat_base(request)

    def create_folder(self, request):
        """创建目录

        :param request:
        :return:
        """
        assert isinstance(request, CreateFolderRequest)
        check_params_ret = self._check_params(request)
        if check_params_ret is not None:
            return check_params_ret

        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        cos_path = request.get_cos_path()
        expired = int(time.time()) + self._expired_period
        sign = auth.sign_more(bucket, cos_path, expired)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['Content-Type'] = 'application/json'
        http_header['User-Agent'] = self._config.get_user_agent()

        http_body = dict()
        http_body['op'] = 'create'
        http_body['biz_attr'] = request.get_biz_attr()

        timeout = self._config.get_timeout()
        return self.send_request('POST', bucket, cos_path, headers=http_header, data=json.dumps(http_body), timeout=timeout)

    def list_folder(self, request):
        """list目录

        :param request:
        :return:
        """
        assert isinstance(request, ListFolderRequest)
        check_params_ret = self._check_params(request)
        if check_params_ret is not None:
            return check_params_ret

        http_body = dict()
        http_body['op'] = 'list'
        http_body['num'] = request.get_num()

        http_body['context'] = request.get_context()

        auth = cos_auth.Auth(self._cred)
        bucket = request.get_bucket_name()
        list_path = request.get_cos_path() + request.get_prefix()
        expired = int(time.time()) + self._expired_period
        sign = auth.sign_more(bucket, list_path, expired)

        http_header = dict()
        http_header['Authorization'] = sign
        http_header['User-Agent'] = self._config.get_user_agent()

        timeout = self._config.get_timeout()
        return self.send_request('GET', bucket, list_path, headers=http_header, params=http_body, timeout=timeout)
