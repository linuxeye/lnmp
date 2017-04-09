#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import re


class ParamCheck(object):
    """BaseRequest基本类型的请求"""
    def __init__(self):
        self._err_tips = u''

    def get_err_tips(self):
        """获取错误信息

        :return:
        """
        return self._err_tips

    def check_param_unicode(self, param_name, param_value):
        """检查参数是否是unicode

        :param param_name: param_name 参数名
        :param param_value: param_value 参数值
        :return:
        """
        if param_value is None:
            self._err_tips = param_name + ' is None!'
            return False
        if not isinstance(param_value, unicode):
            self._err_tips = param_name + ' is not unicode!'
            return False
        return True

    def check_param_int(self, param_name, param_value):
        """检查参数是否是int

        :param param_name: param_name 参数名
        :param param_value: param_value 参数值
        :return:
        """
        if param_value is None:
            self._err_tips = param_name + ' is None!'
            return False
        if not isinstance(param_value, int):
            self._err_tips = param_name + ' is not int!'
            return False
        return True

    def check_cos_path_valid(self, cos_path, is_file_path):
        """检查cos_path是否合法

        路径必须以/开始,文件路径则不能以/结束, 目录路径必须以/结束

        :param cos_path:
        :param is_file_path:
        :return: True for valid path, other False
        """
        if cos_path[0] != u'/':
            self._err_tips = 'cos path must start with /'
            return False

        last_letter = cos_path[len(cos_path) - 1]
        if is_file_path and last_letter == u'/':
            self._err_tips = 'for file operation, cos_path must not end with /'
            return False
        elif not is_file_path and last_letter != u'/':
            self._err_tips = 'for folder operation, cos_path must end with /'
            return False
        else:
            pass

        illegal_letters = ['?', '*', ':', '|', '\\', '<', '>', '"']
        for illegal_letter in illegal_letters:
            if cos_path.find(illegal_letter) != -1:
                self._err_tips = 'cos path contain illegal letter %s' % illegal_letter
                return False

        pattern = re.compile(r'/(\s*)/')
        if pattern.search(cos_path):
            self._err_tips = 'cos path contain illegal letter / /'
            return False
        return True

    def check_not_cos_root(self, cos_path):
        """检查不是cos的根路径

        不能对根路径操作的有 1 update 2 create 3 delete
        :param cos_path:
        :return:
        """
        if cos_path == u'/':
            self._err_tips = 'bucket operation is not supported by sdk,'
            ' please use cos console: https://console.qcloud.com/cos'
            return False
        else:
            return True

    def check_local_file_valid(self, local_path):
        """检查本地文件有效(存在并且可读)

        :param local_path:
        :return:
        """
        if not os.path.exists(local_path):
            self._err_tips = 'local_file %s not exist!' % local_path
            return False
        if not os.path.isfile(local_path):
            self._err_tips = 'local_file %s is not regular file!' % local_path
            return False
        if not os.access(local_path, os.R_OK):
            self._err_tips = 'local_file %s is not readable!' % local_path
            return False
        return True

    def check_slice_size(self, slice_size):
        """检查分片大小有效

        :param slice_size:
        :return:
        """
        min_size = 64 * 1024           # 512KB
        max_size = 3 * 1024 * 1024     # 20MB

        if max_size >= slice_size >= min_size:
            return True
        else:
            self._err_tips = 'slice_size is invalid, only accept [%d, %d]' \
                    % (min_size, max_size)
            return False

    def check_insert_only(self, insert_only):
        """检查文件上传的insert_only参数

        :param insert_only:
        :return:
        """
        if insert_only != 1 and insert_only != 0:
            self._err_tips = 'insert_only only support 0 and 1'
            return False
        else:
            return True

    def check_move_over_write(self, to_over_write):
        """检查move的over write标志

        :param to_over_write:
        :return:
        """
        if to_over_write != 1 and to_over_write != 0:
            self._err_tips = 'to_over_write only support 0 and 1'
            return False
        else:
            return True

    def check_file_authority(self, authority):
        """检查文件的authority属性

        合法的取值只有eInvalid, eWRPrivate, eWPrivateRPublic和空值
        :param authority:
        :return:
        """
        if authority != u''and authority != u'eInvalid' and authority != u'eWRPrivate' and authority != u'eWPrivateRPublic':
            self._err_tips = 'file authority valid value is: eInvalid, eWRPrivate, eWPrivateRPublic'
            return False
        else:
            return True

    def check_x_cos_meta_dict(self, x_cos_meta_dict):
        """检查x_cos_meta_dict, key和value都必须是UTF8编码

        :param x_cos_meta_dict:
        :return:
        """
        prefix_len = len('x-cos-meta-')
        for key in x_cos_meta_dict.keys():
            if not self.check_param_unicode('x-cos-meta-key', key):
                return False
            if not self.check_param_unicode('x-cos-meta-value', x_cos_meta_dict[key]):
                return False
            if key[0:prefix_len] != u'x-cos-meta-':
                self._err_tips = 'x-cos-meta key must start with x-cos-meta-'
                return False
            if len(key) == prefix_len:
                self._err_tips = 'x-cos-meta key must not just be x-cos-meta-'
                return False
            if len(x_cos_meta_dict[key]) == 0:
                self._err_tips = 'x-cos-meta value must not be empty'
                return False
        return True

    def check_update_flag(self, flag):
        """检查更新文件的flag

        :param flag:
        :return:
        """
        if flag == 0:
            self._err_tips = 'no any attribute to be updated!'
            return False
        else:
            return True

    def check_list_order(self, list_order):
        """ 检查list folder的order

        :param list_order: 合法取值0(正序), 1(逆序)
        :return:
        """
        if list_order != 0 and list_order != 1:
            self._err_tips = 'list order is invalid, please use 0(positive) or 1(reverse)!'
            return False
        else:
            return True

    def check_list_pattern(self, list_pattern):
        """检查list folder的pattern

        :param list_pattern: 合法取值eListBoth, eListDirOnly, eListFileOnly
        :return:
        """
        if list_pattern != u'eListBoth' and list_pattern != u'eListDirOnly' and list_pattern != u'eListFileOnly':
            self._err_tips = 'list pattern is invalid, please use eListBoth or eListDirOnly or eListFileOnly'
            return False
        else:
            return True
