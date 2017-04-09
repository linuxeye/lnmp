#!/usr/bin/env python
# -*- coding: utf-8 -*-


class CosRegionInfo(object):

    def __init__(self, region=None, hostname=None, download_hostname=None, *args, **kwargs):
        self._hostname = None
        self._download_hostname = None

        if region in ['sh', 'shanghai']:
            self._hostname = 'sh.file.myqcloud.com'
            self._download_hostname = 'cossh.myqcloud.com'

        elif region in ['gz', 'guangzhou']:
            self._hostname = 'gz.file.myqcloud.com'
            self._download_hostname = 'cosgz.myqcloud.com'

        elif region in ['tj', 'tianjin', 'tianjing']:  # bug: for compact previous release
            self._hostname = 'tj.file.myqcloud.com'
            self._download_hostname = 'costj.myqcloud.com'

        elif region in ['sgp', 'singapore']:
            self._hostname = 'sgp.file.myqcloud.com'
            self._download_hostname = 'cosspg.myqcloud.com'

        elif region is not None:
            self._hostname = '{region}.file.myqcloud.com'.format(region=region)
            self._download_hostname = 'cos{region}.myqcloud.com'.format(region=region)
        else:
            if hostname and download_hostname:
                self._hostname = hostname
                self._download_hostname = download_hostname
            else:
                raise ValueError("region or [hostname, download_hostname] must be set, and region should be sh/gz/tj/sgp")

    @property
    def hostname(self):
        assert self._hostname is not None
        return self._hostname

    @property
    def download_hostname(self):
        assert self._download_hostname is not None
        return self._download_hostname


class CosConfig(object):
    """CosConfig 有关cos的配置"""

    def __init__(self, timeout=300, sign_expired=300, enable_https=False, *args, **kwargs):
        self._region = CosRegionInfo(*args, **kwargs)
        self._user_agent = 'cos-python-sdk-v4'
        self._timeout = timeout
        self._sign_expired = sign_expired
        self._enable_https = enable_https
        if self._enable_https:
            self._protocol = "https"
        else:
            self._protocol = "http"

    def get_endpoint(self):
        """获取域名地址

        :return:
        """
        # tmpl = "%s://%s/files/v2"
        return self._protocol + "://" + self._region.hostname + "/files/v2"

    def get_download_hostname(self):
        return self._region.download_hostname

    def get_user_agent(self):
        """获取HTTP头中的user_agent

        :return:
        """
        return self._user_agent

    def set_timeout(self, time_out):
        """设置连接超时, 单位秒

        :param time_out:
        :return:
        """
        assert isinstance(time_out, int)
        self._timeout = time_out

    def get_timeout(self):
        """获取连接超时，单位秒

        :return:
        """
        return self._timeout

    def set_sign_expired(self, expired):
        """设置签名过期时间, 单位秒

        :param expired:
        :return:
        """
        assert isinstance(expired, int)
        self._sign_expired = expired

    def get_sign_expired(self):
        """获取签名过期时间, 单位秒

        :return:
        """
        return self._sign_expired

    @property
    def enable_https(self):
        assert self._enable_https is not None
        return self._enable_https

    @enable_https.setter
    def enable_https(self, val):
        if val != self._enable_https:
            if val:
                self._enable_https = val
                self._protocol = "https"
            else:
                self._enable_https = val
                self._protocol = "http"
