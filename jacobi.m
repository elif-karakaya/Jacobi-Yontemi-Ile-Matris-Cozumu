function jacobi_main()
    clc;
    n = input('Matrisin boyutunu girin (n): ');

    A = zeros(n);
    B = zeros(n, 1);
    X0 = zeros(n, 1);

    fprintf('\nKatsayilar matrisini girin (A):\n');
    for i = 1:n
        for j = 1:n
            A(i,j) = input(sprintf('A(%d,%d): ', i, j));
        end
    end

    fprintf('\nSonuc matrisini girin (B):\n');
    for i = 1:n
        B(i) = input(sprintf('B(%d): ', i));
    end

    fprintf('\nBaslangic tahminini girin (X0):\n');
    for i = 1:n
        X0(i) = input(sprintf('X0(%d): ', i));
    end

    tol = input('\nDurdurma kistasini girin (E): ');

    fprintf('\nGirilen sistem:\n');
    matrisYazdir(A, B);

    if ~kosegenBaskinMi(A)
        fprintf('Matris kosegen baskin degil. Satir degisiklikleri yapiliyor...\n');
        [A, B] = matrisiKosegenBaskinYap(A, B);
        fprintf('\nDuzenlenmis sistem:\n');
        matrisYazdir(A, B);
        if ~kosegenBaskinMi(A)
            fprintf('UYARI: Matris tam kosegen baskin hale getirilemedi. Yontem yakinsemeyebilir.\n');
        else
            fprintf('Matris kosegen baskin hale getirildi.\n');
        end
    else
        fprintf('Matris zaten kosegen baskin.\n');
    end

    fprintf('\nJacobi yontemi uygulanıyor...\n');
    maksimumIterasyon = 100;
    jacobiYontemi(A, B, X0, tol, maksimumIterasyon);
end

function matrisYazdir(A, B)
    [n, ~] = size(A);
    for i = 1:n
        fprintf('%10.5f ', A(i, :));
        fprintf('| %10.5f\n', B(i));
    end
end

function sonuc = kosegenBaskinMi(A)
    n = size(A, 1);
    sonuc = true;
    for i = 1:n
        diagVal = abs(A(i,i));
        rowSum = sum(abs(A(i,:))) - diagVal;
        if diagVal <= rowSum
            sonuc = false;
            return;
        end
    end
end

function [A, B] = matrisiKosegenBaskinYap(A, B)
    n = size(A, 1);
    for i = 1:n
        diagVal = abs(A(i,i));
        rowSum = sum(abs(A(i,:))) - diagVal;
        if diagVal <= rowSum
            for k = i+1:n
                diagAlt = abs(A(k,i));
                rowSumAlt = sum(abs(A(k,:))) - diagAlt;
                if diagAlt > rowSumAlt && diagAlt > diagVal
                    fprintf('Satir %d ve %d degistiriliyor...\n', i, k);
                    A([i k], :) = A([k i], :);
                    B([i k]) = B([k i]);
                    break;
                end
            end
        end
    end
end

function hata = bagilHataHesapla(Xeski, Xyeni)
    fark = abs((Xyeni - Xeski) ./ (Xyeni + eps));
    hata = max(fark);
end

function jacobiYontemi(A, B, X0, tol, maxIter)
    n = length(B);
    X = X0;
    Xeski = X0;
    fprintf('\nIterasyon Sonuclari:\n');
    fprintf('------------------------------------------------------------\n');
    
    for iter = 1:maxIter
        for i = 1:n
            toplam = B(i);
            for j = 1:n
                if j ~= i
                    toplam = toplam - A(i,j) * Xeski(j);
                end
            end
            X(i) = toplam / A(i,i);
        end
        hata = bagilHataHesapla(Xeski, X);
        cozumYazdir(X, iter, hata);
        if hata < tol
            break;
        end
        Xeski = X;
    end

    fprintf('------------------------------------------------------------\n');
    fprintf('\nSonuc (Iterasyon %d):\n', iter);
    for i = 1:n
        fprintf('X(%d) = %.8f\n', i, X(i));
    end
end

function cozumYazdir(X, iter, hata)
    fprintf('Iterasyon %3d: ', iter);
    for i = 1:length(X)
        fprintf('X[%d] = %10.5f ', i, X(i));
    end
    fprintf('| Hata: %12.8f\n', hata);
end
