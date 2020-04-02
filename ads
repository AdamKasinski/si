from _collections import deque
import itertools
from psychopy import core


class Szklanki:
    def __init__(self):
        self.liczba = int(self.ile())
        self.pojemność = self.poj()
        self.koniec = self.kon()
        self.odwiedzone = {}
        self.kolejka = deque()
        self.pocz = []
        for i in range(self.liczba):
            self.pocz.append(0)
        self.kolejka.append([self.pocz,0])
        self.odwiedzone[0] = self.pocz

    def get_poj(self):
        return self.pojemność

    def get_kon(self):
        return self.koniec

    def ile(self):
        ile = input("Proszę wpisać ilość szklanek: ")
        return ile

    def poj(self):
        poj = input("Proszę wpisać pojemność szklanek: ")
        pojemność = []
        for i in poj.split():
            z = int(i)
            pojemność.append(z)
        return pojemność

    def kon(self):
        wyj = input("Proszę wpisać stan szklanek na końcu: ")
        koniec = []
        for i in wyj.split():
            z = int(i)
            koniec.append(z)
        return koniec

    def wstep(self, pojemnosc, koniec):
        lista = []
        for i in range(min(pojemnosc)+2):
            a = 0
            for j in pojemnosc:
                if j%(i+1) == 0:
                    a +=1
            if a == len(pojemnosc):
                lista.append(i+1)
        nwd = max(lista)
        for i in koniec:
            if i%nwd != 0:
                return False
        return True

    def kol(self,ustawienie,ust1):
        for i in range(len(ustawienie)):
            if ustawienie[i] == ust1[i]:
                return True
        if 0 in ustawienie:
            return True
        return False


    def przelej(self, z, do, ustawienie,poziom):
        if ustawienie[do][0] != ustawienie[do][1] and ustawienie[z][1] != 0:
            if ustawienie[z][1] > ustawienie[do][0] - ustawienie[do][1]:
                dodatkowe_do = ustawienie[do][1]
                ustawienie[do][1] = ustawienie[do][0]
                dodatkowe_z = ustawienie[z][1]
                ustawienie[z][1] = ustawienie[z][1] - ustawienie[do][0] + dodatkowe_do
            else:
                dodatkowe_do = ustawienie[do][1]
                ustawienie[do][1] = ustawienie[do][1] + ustawienie[z][1]
                dodatkowe_z = ustawienie[z][1]
                ustawienie[z][1] = 0
            ust = []
            for i in range(len(ustawienie)):
                ust.append(ustawienie[i][1])
            ustawienie[z][1] = dodatkowe_z
            ustawienie[do][1] = dodatkowe_do
            a = 0
            il = sum(ust)
            if il >= sum(self.koniec):
                if self.kol(ust,self.pojemność):
                    if il in self.odwiedzone.keys():
                        for odw in self.odwiedzone[il]:
                            if odw == ust:
                                a+=1
                                break
                        if a == 0:
                            self.odwiedzone[il].append(ust)
                            self.kolejka.append([ust,poziom+1])
                    else:
                        self.odwiedzone[il] = [ust]
                        self.kolejka.append([ust,poziom+1])

    def wylej(self, z, ustawienie,poziom):
        if ustawienie[z][1] != 0 and ustawienie[z][0] != 0:
            dod = ustawienie[z][1]
            ustawienie[z][1] = 0
            ust = []
            for i in range(len(ustawienie)):
                ust.append(ustawienie[i][1])
            ustawienie[z][1] = dod
            a = 0
            il = sum(ust)
            if il >= sum(self.koniec):
                if self.kol(ust, self.pojemność):
                    if il in self.odwiedzone.keys():
                        for odw in self.odwiedzone[il]:
                            if odw == ust:
                                a += 1
                        if a == 0:
                            self.odwiedzone[il].append(ust)
                            self.kolejka.append([ust,poziom+1])
                    else:
                        self.odwiedzone[il] = [ust]
                        self.kolejka.append([ust,poziom+1])
    def nalej(self, do, ustawienie,poziom):
        if ustawienie[do][1] != ustawienie[do][0] and ustawienie[do][0] != 0:
            dod = ustawienie[do][1]
            ustawienie[do][1] = ustawienie[do][0]
            ust = []
            for i in range(len(ustawienie)):
                ust.append(ustawienie[i][1])
            ustawienie[do][1] = dod
            a = 0
            il = sum(ust)
            if il >= sum(self.koniec):
                if self.kol(ust, self.pojemność):
                    if il in self.odwiedzone.keys():
                        for odw in self.odwiedzone[il]:
                            if odw == ust:
                                a +=1
                                break
                        if a == 0:
                            self.odwiedzone[il].append(ust)
                            self.kolejka.append([ust,poziom+1])
                    else:
                        self.odwiedzone[il] = [ust]
                        self.kolejka.append([ust,poziom+1])

    def akcje(self, ustawienie,poziom):
        hasla = []
        rzeczy = dict()
        for i in range(len(ustawienie)):
            hasla.append(i)
            rzeczy[i] = [self.pojemność[i],ustawienie[i]]
        ust = [i for i in rzeczy.values()]
        permutacje = [i for i in itertools.permutations(hasla,2)]
        for i in range(len(permutacje)):
            self.przelej(permutacje[i][0], permutacje[i][1], ust,poziom)
        for i in range(len(ust)):
            self.nalej(i, ust, poziom)
            self.wylej(i, ust, poziom)

    def szukaj(self):
        if self.wstep(self.pojemność,self.koniec):
            clock = core.Clock()
            while len(self.kolejka) != 0:
                ustaw = self.kolejka.popleft()
                ustawienie = ustaw[0]
                poz = ustaw[1]
                if ustawienie == self.koniec:
                    return clock.getTime(), poz
                self.akcje(ustawienie,poz)
                #print(self.kolejka)
                #print(self.odwiedzone)
        return -1
