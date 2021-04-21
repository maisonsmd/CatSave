#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>

#include "monthlylist.h"
#include "typefilterproxymodel.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication::setApplicationName("CatSave");
    QApplication::setOrganizationName("maisonsmd");

    QApplication app(argc, argv);
    QIcon::setThemeName("CatSave");

    QQmlApplicationEngine engine;
    MonthlyList monthlyList;
    auto * expenseProxy = new TypeFilterProxyModel(nullptr, Enums::RecordType::EXPENSE);
    auto * incomeProxy = new TypeFilterProxyModel(nullptr, Enums::RecordType::INCOME);
    auto * debtProxy = new TypeFilterProxyModel(nullptr, Enums::RecordType::DEBT);

    expenseProxy->setSourceModel(&monthlyList);
    incomeProxy->setSourceModel(&monthlyList);
    debtProxy->setSourceModel(&monthlyList);

    engine.rootContext()->setContextProperty("monthlyList", &monthlyList);
    engine.rootContext()->setContextProperty("expenseProxy", expenseProxy);
    engine.rootContext()->setContextProperty("incomeProxy", incomeProxy);
    engine.rootContext()->setContextProperty("debtProxy", debtProxy);

    qmlRegisterType<Enums>("CatSave", 1, 0, "Enums");

    engine.load(QUrl("qrc:/main.qml"));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
