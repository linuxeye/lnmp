#!/usr/bin/env python
# -*- coding:utf-8 -*-

from cos_params_check import ParamCheck


class CredInfo(object):
    """CredInfo用户的身份信息"""
    def __init__(self, appid, secret_id, secret_key):
        self._appid = appid
        self._secret_id = secret_id
        self._secret_key = secret_key
        self._param_check = ParamCheck()

    def get_appid(self):
        return self._appid

    def get_secret_id(self):
        return self._secret_id

    def get_secret_key(self):
        return self._secret_key

    def check_params_valid(self):
        if not self._param_check.check_param_int('appid', self._appid):
            return False
        if not self._param_check.check_param_unicode('secret_id', self._secret_id):
            return False
        return self._param_check.check_param_unicode('secret_key', self._secret_key)

    def get_err_tips(self):
        """获取错误信息

        :return:
        """
        return self._param_check.get_err_tips()
