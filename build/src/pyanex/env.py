from os import getenv, system
from sys import argv
import logging as log
from pathlib import Path

class Env:
    def __init__(self) -> None:
        self.debug = getenv('APP_DEBUG',False)
        self.log = {
            'format':getenv('APP_LOG_FORMAT',
                '%(asctime)s [%(levelname)s] - %(name)s - %(message)s')
        }
        self.inventory_dir = getenv('APP_INVENTORY_DIR','/usr/local/app/inventory')
        self.playbook_dir = getenv('APP_PLAYBOOK_DIR','/usr/local/app/playbook')
        self.key = getenv('APP_KEY_DIR','/usr/local/app/.key')
        self.inventory = self.inventory_dir
        self.playbook = None
        self.tags = []
        self.skip = []
        self.limit = None
        self.vault = []
        self.args = argv
        args = argv
        while args:
            arg = args[0]
            if len(args) > 1:
                opt = args[1]
            else:
                opt = None
            args.pop(0)
            print(arg, opt)
            self._read_arg(arg,opt)
        if self.debug:
            print(self.__dict__)
        if self.inventory is None or self.playbook is None:
            if self.debug:
                print(self.inventory, self.playbook)
            log.error('Playbook and inventory args are required!')
            exit('Playbook and inventory args are required!')

    def _read_arg(self,arg:str,opt:str|None):
        match arg:
            case '--debug':
                self.debug = True
                log.info(f'self.debug: {self.debug}')
            case '-p' | '--play' | '--playbook':
                if opt:
                    self.playbook = Path(f'{self.playbook_dir}/{opt}.yml')
            case '-i' | '--inv' | '--inventory':
                if opt:
                    self.inventory = Path(f'{self.inventory_dir}/{opt}.yml')
            case '-t' | '--tag' | '--tags':
                if opt:
                    self.tags = opt.split(',')
            case '-s' | '--skip' | '--skip-tags':
                if opt:
                    self.skip = opt.split(',')
            case '-l' | '--limit':
                if opt:
                    self.limit = opt
            case '-v' | '--vault' | '--vault-pass-file':
                if opt:
                    self.vault = opt.split(',')

    def execute(self):
        optional = ''
        if self.tags:
            optional = optional + f' --tags {self.tags}'
        if self.skip:
            optional = optional + f' --skip-tags {self.skip}'
        if self.limit:
            optional = optional + f' --limit {self.limit}'
        if self.vault:
            for v in self.vault:
                optional = optional + f' --vault-pass-file {v}'
        cmd=f'''python3 -m ansible playbook -i {self.inventory} \\
{self.playbook} {optional}'''
        system(cmd)
