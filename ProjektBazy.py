#!/usr/bin/env python
# coding: utf-8

# In[29]:


import psycopg2
def lista_k(numer_wyborow):
    try:
        cur = con.cursor()
        cur.execute("SELECT * FROM kandydat WHERE nr_wyborow = numer_wyborow")
        rows = cur.fetchall()
        for r in rows:
            print("Numer wyborów: ",r[1],"| Numer indeksu: ",r[0],"| Imie: ",r[4], "| Nazwisko: ",r[5])
        con.commit()
        cur.close()
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
def lista_w():
    try:
        cur = con.cursor()
        cur.execute("SELECT * FROM wybory")
        rows = cur.fetchall()
        for r in rows:
            print("Numer wyborów: ",r[0],"| Nazwa: ",r[1],"| Czy opublikowane: ",r[7])
        con.commit()
        cur.close()
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
                    
def logowanie_w(numer):
    try:
        cur = con.cursor()
        cur.execute("SELECT logowanie(%s)",(numer,))
        print("Udało się zalogować.")
        con.commit()
        cur.close()
        return True
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
                    
def logowanie_k(nr,haslo):
    try:
        cur = con.cursor()
        cur.execute("SELECT logowanie(%s,%s)",(nr,haslo))
        print("Udało się zalogować.")
        con.commit()
        cur.close()
        return True 
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
                    
def glosuj(nr_wyb,nr_kandydata,nr_wyborcy):
    try:
        cur = con.cursor()
        cur.execute("SELECT nowy_glos(%s,%s,%s)",(nr_wyb,nr_kandydata,nr_wyborcy))
        rows = cur.fetchall()
        for r in rows:
            print(r[0])
        con.commit()
        cur.close()
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
    
def nowy_kandydat(nr_k,imie,nazwisko,stanowisko,nr_wyb):
    try:
        cur = con.cursor()
        cur.execute("SELECT nowy_kandydat(%s,%s,%s,%s,%s)",(nr_k,imie,nazwisko,stanowisko,nr_wyb))
        rows = cur.fetchall()
        for r in rows:
            print(r[0])
        con.commit()
        cur.close()
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
    
def wprowadzenie():
    while 1:
        try:
            b = int(input())
            return b
        except ValueError:
            print("Źle wprowadzono liczbę, spróbuj jeszcze raz: ")
                    
def liczba_posad(nr_wyb):
    try:
        cur = con.cursor()
        cur.execute("SELECT liczba_posad FROM wybory WHERE nr_wyborow = %s",(nr_wyb,))
        rows = cur.fetchall()
        for r in rows:
            a = int(r[0])
        con.commit()
        cur.close()
        return a
    except Exception:
        print("Nie ma takich wyborów.")
        poczatek()
            
def ogladaj(nr_wyb):
    try: 
        l = liczba_posad(nr_wyb)
        cur = con.cursor()
        cur.execute("SELECT ogladaj(%s,%s)",(nr_wyb,l))
        rows = cur.fetchall()
        for r in rows:
            print(r[0])
        con.commit()
        cur.close()
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
        
def nowe_wybory(nr_komisji, nr_wyborow, nazwa, stanowisko, liczba_posad, termin_zglaszania, start_glosowania, koniec_glosowania):
    try:
        cur = con.cursor()
        cur.execute("SELECT nowe_wybory(%s,%s,%s,%s,%s,%s,%s,%s)",(
            nr_komisji, nr_wyborow, nazwa, stanowisko, liczba_posad, termin_zglaszania, start_glosowania, koniec_glosowania))
        rows = cur.fetchall()
        for r in rows:
            print(r[0])
        con.commit()
        cur.close()
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
        
def nowy_wyborca(nr_indeksu,id_komisji,imie,nazwisko):
    try:
        cur = con.cursor()
        cur.execute("SELECT nowy_wyborca(%s,%s,%s,%s)",(nr_indeksu,id_komisji,imie,nazwisko))
        rows = cur.fetchall()
        for r in rows:
            print(r[0])
        con.commit()
        cur.close()
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
                    
def opublikuj(nr_wyb):
    try:
        cur = con.cursor()
        cur.execute("SELECT opublikuj(%s)",(nr_wyb,))
        rows = cur.fetchall()
        for r in rows:
            print(r[0])
        con.commit()
        cur.close()
    except Exception as err:
        print ("Oops! Wystąpił błąd:", err)
        poczatek()
                    
def czynnosc_wyborca(numer):
    print("\n Jaką czynność chcesz wykonać?")
    print("Wpisz: \n 1 jeśli chcesz zgłosić kandydata w wyborach.")
    print("\n 2 jeśli chcesz oddać głos w wyborach.")
    print("\n 3 jeśli chcesz obejrzeć wyniki wyborów.")
    print("\n 4 powrót.")
    a = wprowadzenie()
    if a == 1:
        print("Podaj numer indeksu kandydata:")
        nr_k = wprowadzenie()
        print("Podaj imię kandydata:")
        imie = input()
        print("Podaj nazwisko kandydata:")
        nazwisko = input()
        print("Podaj stanowisko, na które kandydat ma kandydować:")
        stanowisko = input()
        print("Podaj numer wyborów, w których ma brać udział")
        nr_wyb = wprowadzenie()
        nowy_kandydat(nr_k,imie,nazwisko,stanowisko,nr_wyb)
        czynnosc_wyborca(numer)
    elif a == 2:
        print("Podaj numer wyborów, w których chcesz oddać głos:")
        lista_w()
        nr_wyb = wprowadzenie()
        print("Podaj numer indeksu kandydata:")
        lista_k(nr_wyb)
        nr_k = wprowadzenie()
        glosuj(nr_wyb,nr_k,numer)
        czynnosc_wyborca(numer)
    elif a == 3:
        print("Podaj numer wyborów, których wyniki chcesz obejrzeć:")
        lista_w()
        nr_wyb = wprowadzenie()
        ogladaj(nr_wyb)
        czynnosc_wyborca(numer)
    elif a == 4:
        poczatek()
    else: 
        print("Należy podać jedną z podanych liczb!")
        czynnosc_wyborca(numer)
        
        
def czynnosc_komisja(id_komisji):
    print("\n Jaką czynność chcesz wykonać?")
    print("Wpisz: \n 1 jeśli chcesz dodać nowe wybory.")
    print("\n 2 jeśli chcesz dodać nowego wyborcę.")
    print("\n 3 jeśli chcesz opublikować wybory.")
    print("\n 4 powrót.")
    b = wprowadzenie()
    if b == 1:
        print("Podaj numer nowych wyborów:")
        nr_wyb = wprowadzenie()
        print("Podaj nazwę nowych wyborów:")
        nazwa = input()
        print("Podaj stanowisko:")
        stanowisko = input()
        print("Podaj liczbę posad:")
        liczba_posad = wprowadzenie()
        print("Podaj termin zgłaszania kandydatów:")
        termin_zgl = input("RRRR-MM-DD")
        print("Podaj datę startu głosowania:")
        start_gl = input("RRRR-MM-DD")
        print("Podaj datę końca głosowania:")
        koniec_gl = input("RRRR-MM-DD")
        nowe_wybory(id_komisji,nr_wyb,nazwa,stanowisko,liczba_posad,termin_zgl,start_gl,koniec_gl)
        czynnosc_komisja(id_komisji)
    elif b == 2:
        print("Podaj numer indeksu nowego wyborcy:")
        nr_indeksu = wprowadzenie()
        print("Podaj imię nowego wyborcy:")
        imie = input()
        print("Podaj nazwisko nowego wyborcy:")
        nazwisko = input()
        nowy_wyborca(nr_indeksu,id_komisji,imie,nazwisko)
        czynnosc_komisja(id_komisji)
    elif b == 3:
        lista_w()
        print("Podaj numer wyborów, które chcesz opublikować:")
        nr_wyb = wprowadzenie()
        opublikuj(nr_wyb)
        czynnosc_komisja(id_komisji)
    elif b == 4:
        poczatek()
    else:
        print("Należy podać jedną z podanych liczb!")
        czynnosc_komisja(id_komisji)
    
        
def poczatek():
    print("Witaj na stronie startowej samorządu studenckiego. Wpisz: ")
    print("\n 1 jeśli chcesz się zalogować jako wyborca.")
    print("\n 2 jeśli chcesz się zalogować jako członek komisji.")
    print("\n 3 jeśli chcesz zakończyć działanie.")
    n = wprowadzenie()
    if n == 1:
        indeks = int(input("Podaj numer indeksu: "))
        if logowanie_w(indeks):
            czynnosc_wyborca(indeks)
    elif n==2:
        id_komisji = int(input("Podaj id komisji: "))
        haslo = input("Podaj haslo: ")
        if logowanie_k(id_komisji,haslo):
            czynnosc_komisja(id_komisji)
    elif n == 3:
        print("Do widzenia!")
    else:
        print("Należy podać jedną z podanych liczb!")
        poczatek()


# In[ ]:


con = psycopg2.connect( host = "localhost", database = "Projekt", user = "postgres", password = "password")
poczatek()
con.close()


# In[ ]:




